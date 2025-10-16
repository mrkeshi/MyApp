from rest_framework import viewsets, mixins, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Avg, Count
from drf_spectacular.utils import extend_schema, OpenApiResponse
from .models import Event, EventReview
from .serializers import EventSerializer, EventDetailSerializer, EventReviewSerializer, EventReviewCreateSerializer

@extend_schema(
    tags=["Events"],
    summary="List events (user's province)",
    description="Returns events only for the authenticated user's province. Staff users see all.",
    responses={200: OpenApiResponse(response=EventSerializer(many=True), description="Event list")}
)
class EventViewSet(mixins.ListModelMixin,
                   mixins.RetrieveModelMixin,
                   viewsets.GenericViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        if self.action == "retrieve":
            return EventDetailSerializer
        return EventSerializer

    def get_queryset(self):
        qs = Event.objects.all().annotate(
            average_rating=Avg("reviews__rating"),
            reviews_count=Count("reviews"),
        ).prefetch_related("reviews__user")
        user = self.request.user
        if user.is_staff or user.is_superuser:
            province_id = self.request.query_params.get("province_id")
            if province_id:
                qs = qs.filter(province_id=province_id)
            return qs
        if getattr(user, "province_id", None):
            return qs.filter(province_id=user.province_id)
        return qs.none()

    @extend_schema(
        tags=["Events"],
        summary="Retrieve event (user's province only)",
        responses={200: EventDetailSerializer}
    )
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)

    @extend_schema(
        tags=["Events"],
        summary="List reviews of an event",
        responses={200: OpenApiResponse(response=EventReviewSerializer(many=True), description="Reviews")}
    )
    @action(detail=True, methods=["get"], url_path="reviews", permission_classes=[permissions.IsAuthenticated])
    def reviews(self, request, pk=None):
        event = self.get_object()
        qs = event.reviews.select_related("user").all()
        ser = EventReviewSerializer(qs, many=True, context={"request": request})
        return Response(ser.data)

    @extend_schema(
        tags=["Events"],
        summary="Create or update my review",
        request=EventReviewCreateSerializer,
        responses={200: OpenApiResponse(response=EventReviewSerializer, description="Upserted review")},
    )
    @action(detail=True, methods=["post"], url_path="reviews/my", permission_classes=[permissions.IsAuthenticated])
    def upsert_my_review(self, request, pk=None):
        event = self.get_object()
        ser = EventReviewCreateSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        rating = ser.validated_data["rating"]
        comment = ser.validated_data.get("comment", "")
        obj, _ = EventReview.objects.update_or_create(
            event=event, user=request.user,
            defaults={"rating": rating, "comment": comment}
        )
        return Response(EventReviewSerializer(obj, context={"request": request}).data, status=status.HTTP_200_OK)

    @extend_schema(
        tags=["Events"],
        summary="Get my review",
        responses={200: OpenApiResponse(response=EventReviewSerializer, description="My review or 204 if none")},
    )
    @action(detail=True, methods=["get"], url_path="reviews/my", permission_classes=[permissions.IsAuthenticated])
    def get_my_review(self, request, pk=None):
        event = self.get_object()
        obj = EventReview.objects.filter(event=event, user=request.user).first()
        if not obj:
            return Response(status=status.HTTP_204_NO_CONTENT)
        return Response(EventReviewSerializer(obj, context={"request": request}).data, status=status.HTTP_200_OK)
