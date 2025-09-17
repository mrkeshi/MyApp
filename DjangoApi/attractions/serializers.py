from rest_framework import serializers
from django.db.models import Avg, Count
from .models import Attraction, AttractionPhoto, AttractionReview

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

    class Meta:
        model = AttractionReview
        fields = ("id", "user", "user_display", "rating", "comment", "created_at")
        read_only_fields = ("user", "user_display", "created_at")

    def get_user_display(self, obj):
        return obj.user.get_full_name() or obj.user.username

class AttractionReviewCreateSerializer(serializers.Serializer):
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(allow_blank=True, required=False)
