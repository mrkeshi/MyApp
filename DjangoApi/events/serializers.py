from typing import Optional
from django.utils import timezone
import jdatetime
from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from drf_spectacular.types import OpenApiTypes
from .models import Event, EventReview

_FA_TRANS = str.maketrans("0123456789", "۰۱۲۳۴۵۶۷۸۹")
_JALALI_MONTHS = [
    "فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور",
    "مهر","آبان","آذر","دی","بهمن","اسفند"
]

def to_fa_digits(s: str) -> str:
    return s.translate(_FA_TRANS)

def gregorian_to_jalali_label(dt, with_time: bool = False) -> str:
    if not dt:
        return ""
    dt = timezone.localtime(dt)
    jdt = jdatetime.datetime.fromgregorian(datetime=dt)
    label = f"{jdt.day} {_JALALI_MONTHS[jdt.month - 1]} {jdt.year}"
    if with_time:
        label += f"، {jdt.hour:02d}:{jdt.minute:02d}"
    return to_fa_digits(label)


class EventSerializer(serializers.ModelSerializer):
    cover_image = serializers.ImageField(read_only=True)
    average_rating = serializers.FloatField(read_only=True)
    reviews_count = serializers.IntegerField(read_only=True)
    maps_url = serializers.SerializerMethodField()
    start_at_text = serializers.SerializerMethodField()

    class Meta:
        model = Event
        fields = (
            "id","province","title","short_description","description",
            "registration_cost","discount_code","venue",
            "latitude","longitude","maps_url",
            "cover_image","start_at","start_at_text",
            "average_rating","reviews_count",
        )

    def get_maps_url(self, obj):
        if obj.latitude is not None and obj.longitude is not None:
            lat, lng = float(obj.latitude), float(obj.longitude)
            return f"https://www.google.com/maps/search/?api=1&query={lat},{lng}"
        return None

    def get_start_at_text(self, obj):
        return gregorian_to_jalali_label(obj.start_at, with_time=True)


class EventReviewSerializer(serializers.ModelSerializer):
    user_display = serializers.SerializerMethodField()
    profile_image = serializers.SerializerMethodField()
    created_at_text = serializers.SerializerMethodField()

    class Meta:
        model = EventReview
        fields = (
            "id","user","user_display","profile_image",
            "rating","comment","created_at","created_at_text"
        )
        read_only_fields = ("user","user_display","created_at")

    def get_user_display(self, obj) -> str:
        return obj.user.get_full_name() or obj.user.username

    @extend_schema_field(OpenApiTypes.URI)
    def get_profile_image(self, obj) -> Optional[str]:
        f = getattr(obj.user, "profile_image", None)
        if not f:
            return None
        try:
            url = f.url
        except Exception:
            return None
        request = self.context.get("request")
        return request.build_absolute_uri(url) if request else url

    def get_created_at_text(self, obj) -> str:
        with_time = bool(self.context.get("with_time", False))
        return gregorian_to_jalali_label(obj.created_at, with_time=with_time)


class EventReviewCreateSerializer(serializers.Serializer):
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(allow_blank=True, required=False)


class EventDetailSerializer(EventSerializer):
    reviews = serializers.SerializerMethodField()

    class Meta(EventSerializer.Meta):
        fields = EventSerializer.Meta.fields + ("reviews",)

    def get_reviews(self, obj):
        ctx = {
            "request": self.context.get("request"),
            "with_time": self.context.get("with_time", False),
        }
        return EventReviewSerializer(
            obj.reviews.select_related("user").all(),
            many=True,
            context=ctx,
        ).data
