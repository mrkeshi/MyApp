from django.contrib.contenttypes.models import ContentType
from drf_spectacular.utils import extend_schema, OpenApiResponse
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from attractions.models import Attraction
from events.models import Event
from .models import Bookmark
from .serializers import (
    BookmarkToggleSerializer,
    BookmarkSimpleSerializer,
    TYPE_MAP,
)

@extend_schema(
    tags=["Bookmarks"],
    summary="Toggle bookmark (add/remove)",
    description="Bookmark or unbookmark an attraction or event by type+id.",
    request=BookmarkToggleSerializer,
    responses={200: OpenApiResponse(response=None, description="Toggled")},
)
class ToggleBookmarkView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        ser = BookmarkToggleSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        ct = ser.validated_data["content_type"]
        obj = ser.validated_data["target_obj"]

        bm, created = Bookmark.objects.get_or_create(
            user=request.user, content_type=ct, object_id=obj.id
        )
        if not created:
            bm.delete()
            return Response({"bookmarked": False}, status=status.HTTP_200_OK)
        return Response({"bookmarked": True}, status=status.HTTP_200_OK)

@extend_schema(
    tags=["Bookmarks"],
    summary="List my bookmarks",
    description="Return all bookmarks of the authenticated user. Optional filter by ?type=event|attraction",
    responses={200: OpenApiResponse(response=BookmarkSimpleSerializer(many=True), description="List of bookmarks")},
)
class ListBookmarksView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        type_filter = request.query_params.get("type")
        qs = Bookmark.objects.filter(user=request.user).order_by("-created_at")

        if type_filter in TYPE_MAP:
            app_label, model_name, _ = TYPE_MAP[type_filter]
            ct = ContentType.objects.get(app_label=app_label, model=model_name)
            qs = qs.filter(content_type=ct)

        event_ids = [b.object_id for b in qs if b.content_type.model == "event"]
        attraction_ids = [b.object_id for b in qs if b.content_type.model == "attraction"]

        events = {e.id: e for e in Event.objects.filter(id__in=event_ids)}
        attractions = {a.id: a for a in Attraction.objects.filter(id__in=attraction_ids)}

        out = []
        for b in qs:
            if b.content_type.model == "event":
                inst = events.get(b.object_id)
                if inst:
                    out.append(BookmarkSimpleSerializer.from_instance(inst, "event", b.created_at))
            elif b.content_type.model == "attraction":
                inst = attractions.get(b.object_id)
                if inst:
                    out.append(BookmarkSimpleSerializer.from_instance(inst, "attraction", b.created_at))

        return Response(out, status=status.HTTP_200_OK)
