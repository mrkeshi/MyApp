from rest_framework import serializers
from django.contrib.contenttypes.models import ContentType
from attractions.models import Attraction
from events.models import Event

TYPE_MAP = {
    "attraction": ("attractions", "attraction", Attraction),
    "event": ("events", "event", Event),
}

class BookmarkToggleSerializer(serializers.Serializer):
    type = serializers.ChoiceField(choices=[("attraction", "attraction"), ("event", "event")])
    id = serializers.IntegerField(min_value=1)

    def validate(self, data):
        t = data["type"]
        obj_id = data["id"]
        app_label, model_name, model_cls = TYPE_MAP[t]
        try:
            obj = model_cls.objects.get(pk=obj_id)
        except model_cls.DoesNotExist:
            raise serializers.ValidationError({"id": "Object not found"})
        data["target_obj"] = obj
        data["content_type"] = ContentType.objects.get(app_label=app_label, model=model_name)
        return data

class BookmarkSimpleSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    type = serializers.CharField()
    title = serializers.CharField()
    cover_image = serializers.CharField(allow_null=True)
    address = serializers.CharField(allow_null=True)
    created_at = serializers.DateTimeField()

    @staticmethod
    def from_instance(instance, type_name, created_at):
        cover_url = None
        if getattr(instance, "cover_image", None):
            try:
                cover_url = instance.cover_image.url
            except Exception:
                cover_url = None
        address = getattr(instance, "venue", None)
        return {
            "id": instance.id,
            "type": type_name,
            "title": getattr(instance, "title", str(instance)),
            "cover_image": cover_url,
            "address": address,
            "created_at": created_at,
        }
