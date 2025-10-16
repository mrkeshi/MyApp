from typing import Optional
from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from drf_spectacular.types import OpenApiTypes
from .models import Event, EventReview

class EventSerializer(serializers.ModelSerializer):
    cover_image = serializers.ImageField(read_only=True)
    average_rating = serializers.FloatField(read_only=True)
    reviews_count = serializers.IntegerField(read_only=True)
    maps_url = serializers.SerializerMethodField()

    class Meta:
        model = Event
        fields = (
            "id", "province", "title", "short_description", "description",
            "registration_cost", "discount_code", "venue",
            "latitude", "longitude", "maps_url",
            "cover_image", "start_at",
            "average_rating", "reviews_count",
        )

    def get_maps_url(self, obj):
        if obj.latitude is not None and obj.longitude is not None:
            lat, lng = float(obj.latitude), float(obj.longitude)
            return f"https://www.google.com/maps/search/?api=1&query={lat},{lng}"
        return None

class EventReviewSerializer(serializers.ModelSerializer):
    user_display = serializers.SerializerMethodField()
    profile_image = serializers.SerializerMethodField()

    class Meta:
        model = EventReview
        fields = ("id", "user", "user_display", "profile_image", "rating", "comment", "created_at")
        read_only_fields = ("user", "user_display", "created_at")

    @extend_schema_field(OpenApiTypes.URI)
    def get_profile_image(self, obj) -> Optional[str]:
        user = obj.user
        f = getattr(user, "profile_image", None)
        if not f:
            return None
        try:
            url = f.url
        except Exception:
            return None
        request = self.context.get("request")
        return request.build_absolute_uri(url) if request else url

    def get_user_display(self, obj) -> str:
        return obj.user.get_full_name() or obj.user.username

class EventReviewCreateSerializer(serializers.Serializer):
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(allow_blank=True, required=False)

class EventDetailSerializer(EventSerializer):
    reviews = EventReviewSerializer(many=True, read_only=True)

    class Meta(EventSerializer.Meta):
        fields = EventSerializer.Meta.fields + ("reviews",)
