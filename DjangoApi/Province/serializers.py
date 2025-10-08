from rest_framework import serializers
from .models import Province, ProvincePhoto

class ProvinceSerializer(serializers.ModelSerializer):
    map_image = serializers.ImageField(read_only=True)

    class Meta:
        model = Province
        fields = [
            "id",
            "name_fa",
            "name_en",
            "capital",
            "population",
            "area",
            "description",
            "map_image",
        ]

class ProvincePhotoSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(read_only=True)

    class Meta:
        model = ProvincePhoto
        fields = ("id", "image", "title", "order", "created_at")

class ProvincePhotoSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = ProvincePhoto
        fields = ["id", "title", "order", "created_at", "province_id", "image_url"]

    def get_image_url(self, obj):
        request = self.context.get("request")
        value = getattr(obj, "image", None)
        if not value:
            return None
        url = value.url if hasattr(value, "url") else str(value)
        return request.build_absolute_uri(url) if request else url