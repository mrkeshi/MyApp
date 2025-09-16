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
