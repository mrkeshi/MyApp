from rest_framework import serializers
from django.utils import timezone
import jdatetime

from .models import Attraction, AttractionPhoto, AttractionReview


_FA_TRANS = str.maketrans("0123456789", "۰۱۲۳۴۵۶۷۸۹")
_JALALI_MONTHS = [
    "فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
    "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند",
]

def to_fa_digits(s: str) -> str:
    return s.translate(_FA_TRANS)

def gregorian_to_jalali_label(dt, with_time=False) -> str:
    if not dt:
        return ""
    dt = timezone.localtime(dt)
    jdt = jdatetime.datetime.fromgregorian(datetime=dt)
    label = f"{jdt.day} {_JALALI_MONTHS[jdt.month - 1]} {jdt.year}"
    if with_time:
        label += f"، {jdt.hour:02d}:{jdt.minute:02d}"
    return to_fa_digits(label)


class AttractionPhotoSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(read_only=True)

    class Meta:
        model = AttractionPhoto
        fields = ("id", "image", "title", "order", "created_at")


class AttractionSerializer(serializers.ModelSerializer):
    cover_image = serializers.ImageField(read_only=True)
    average_rating = serializers.FloatField(read_only=True)
    reviews_count = serializers.IntegerField(read_only=True)
    maps_url = serializers.SerializerMethodField()

    class Meta:
        model = Attraction
        fields = (
            "id", "province", "title", "short_description", "description",
            "registration_cost", "discount_code", "venue",
            "latitude", "longitude", "maps_url",
            "cover_image",
            "average_rating", "reviews_count",
        )

    def get_maps_url(self, obj):
        if obj.latitude is not None and obj.longitude is not None:
            lat, lng = float(obj.latitude), float(obj.longitude)
            return f"https://www.google.com/maps/search/?api=1&query={lat},{lng}"
        return None


class AttractionReviewSerializer(serializers.ModelSerializer):
    user_display = serializers.SerializerMethodField()
    created_at_text = serializers.SerializerMethodField()
    profile_image = serializers.SerializerMethodField()

    class Meta:
        model = AttractionReview
        fields = (
            "id", "user", "user_display", "rating", "comment",
            "created_at", "created_at_text", "profile_image"
        )
        read_only_fields = ("user", "user_display", "created_at")

    def get_user_display(self, obj):
        return obj.user.get_full_name() or obj.user.username

    def get_created_at_text(self, obj):
        with_time = bool(self.context.get("with_time", False))
        return gregorian_to_jalali_label(obj.created_at, with_time=with_time)

    def get_profile_image(self, obj):

        user = obj.user
        f = getattr(user, "profile_image", None)
        if not f:
            return ""
        try:
            url = f.url
        except Exception:
            return ""
        request = self.context.get("request")
        return request.build_absolute_uri(url) if request else url

class AttractionReviewCreateSerializer(serializers.Serializer):
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(allow_blank=True, required=False)


class AttractionSearchResultSerializer(serializers.ModelSerializer):
    cover_image_url = serializers.SerializerMethodField()
    cover_image_name = serializers.SerializerMethodField()
    average_rating = serializers.FloatField(read_only=True)

    class Meta:
        model = Attraction
        fields = (
            "id",
            "title",
            "short_description",
            "cover_image_url",
            "cover_image_name",
            "average_rating",
        )

    def get_cover_image_url(self, obj):
        f = getattr(obj, "cover_image", None)
        if not f:
            return ""
        try:
            url = f.url
        except Exception:
            return ""
        request = self.context.get("request")
        return request.build_absolute_uri(url) if request else url

    def get_cover_image_name(self, obj):
        f = getattr(obj, "cover_image", None)
        if not f:
            return ""
        return getattr(f, "name", "")


class AttractionDetailSerializer(AttractionSerializer):
    photos = AttractionPhotoSerializer(many=True, read_only=True)
    reviews = AttractionReviewSerializer(many=True, read_only=True)

    class Meta(AttractionSerializer.Meta):
        fields = AttractionSerializer.Meta.fields + ("photos", "reviews",)
