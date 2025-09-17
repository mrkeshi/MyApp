from rest_framework import viewsets, mixins, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Avg, Count
from drf_spectacular.utils import extend_schema, OpenApiResponse
from .models import Attraction, AttractionReview
from .serializers import (
    AttractionSerializer, AttractionPhotoSerializer,
    AttractionReviewSerializer, AttractionReviewCreateSerializer
)
@extend_schema(
    tags=["Attractions"],
    summary="List attractions (user's province)",
    description="Returns attractions only for the authenticated user's province. Staff users see all.",
    responses={200: OpenApiResponse(response=AttractionSerializer(many=True), description="Attraction list")}
)
class AttractionViewSet(mixins.ListModelMixin,
                        mixins.RetrieveModelMixin,
                        viewsets.GenericViewSet):
    serializer_class = AttractionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = Attraction.objects.all().annotate(
            average_rating=Avg("reviews__rating"),
            reviews_count=Count("reviews"),
        )
        user = self.request.user
        if user.is_staff or user.is_superuser:
            return qs
        if getattr(user, "province_id", None):
            return qs.filter(province_id=user.province_id)
        return qs.none()

    @extend_schema(tags=["Attractions"], summary="Retrieve attraction (user's province only)", responses={200: AttractionSerializer})
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)

    @extend_schema(
        tags=["Attractions"],
        summary="Attraction photos",
        responses={200: OpenApiResponse(response=AttractionPhotoSerializer(many=True), description="Gallery")}
    )
    @action(detail=True, methods=["get"], url_path="photos", permission_classes=[permissions.IsAuthenticated])
    def photos(self, request, pk=None):
        attraction = self.get_object()  # همین فیلتر استان را رعایت می‌کند
        ser = AttractionPhotoSerializer(attraction.photos.all(), many=True, context={"request": request})
        return Response(ser.data)

    @extend_schema(
        tags=["Attractions"],
        summary="List reviews",
        responses={200: OpenApiResponse(response=AttractionReviewSerializer(many=True), description="Reviews")}
    )
    @action(detail=True, methods=["get"], url_path="reviews", permission_classes=[permissions.IsAuthenticated])
    def reviews(self, request, pk=None):
        attraction = self.get_object()
        ser = AttractionReviewSerializer(attraction.reviews.select_related("user"), many=True, context={"request": request})
        return Response(ser.data)

    @extend_schema(
        tags=["Attractions"],
        summary="Get my review",
        responses={200: OpenApiResponse(response=AttractionReviewSerializer, description="My review or 204")}
    )
    @action(detail=True, methods=["get"], url_path="reviews/my", permission_classes=[permissions.IsAuthenticated])
    def get_my_review(self, request, pk=None):
        attraction = self.get_object()
        obj = attraction.reviews.filter(user=request.user).first()
        if not obj:
            return Response(status=status.HTTP_204_NO_CONTENT)
        return Response(AttractionReviewSerializer(obj, context={"request": request}).data)

    @extend_schema(
        tags=["Attractions"],
        summary="Create/Update my review",
        request=AttractionReviewCreateSerializer,
        responses={200: OpenApiResponse(response=AttractionReviewSerializer, description="Upserted review")}
    )
    @action(detail=True, methods=["post"], url_path="reviews/my", permission_classes=[permissions.IsAuthenticated])
    def upsert_my_review(self, request, pk=None):
        attraction = self.get_object()
        ser = AttractionReviewCreateSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        obj, _ = AttractionReview.objects.update_or_create(
            attraction=attraction, user=request.user,
            defaults={"rating": ser.validated_data["rating"], "comment": ser.validated_data.get("comment", "")}
        )
        return Response(AttractionReviewSerializer(obj, context={"request": request}).data, status=status.HTTP_200_OK)
