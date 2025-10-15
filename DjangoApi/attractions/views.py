from rest_framework import viewsets, mixins, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Avg, Count, Q
from drf_spectacular.utils import extend_schema, OpenApiResponse

from Province.models import ProvincePhoto
from Province.serializers import ProvincePhotoSerializer
from .models import Attraction, AttractionReview, AttractionPhoto  # 👈 اضافه شد
from .serializers import (
    AttractionSerializer, AttractionPhotoSerializer, AttractionSearchResultSerializer,
    AttractionReviewSerializer, AttractionReviewCreateSerializer, AttractionDetailSerializer
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

    @extend_schema(
        tags=["Attractions"],
        summary="Retrieve attraction (with photos and reviews)",
        responses={200: AttractionDetailSerializer}
    )
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = AttractionDetailSerializer(instance, context={"request": request})
        return Response(serializer.data)

    @extend_schema(
        tags=["Attractions"],
        summary="Attraction photos",
        responses={200: OpenApiResponse(response=AttractionPhotoSerializer(many=True), description="Gallery")}
    )
    @action(detail=True, methods=["get"], url_path="photos", permission_classes=[permissions.IsAuthenticated])
    def photos(self, request, pk=None):
        attraction = self.get_object()
        ser = AttractionPhotoSerializer(attraction.photos.all(), many=True, context={"request": request})
        return Response(ser.data)

    @extend_schema(
        tags=["Attractions"],
        summary="Province photos (standalone)",
        description="Returns province-level photos (not attraction photos).",
        responses={200: OpenApiResponse(response=ProvincePhotoSerializer(many=True), description="Province photos")}
    )
    @action(
        detail=False,
        methods=["get"],
        url_path=r"province/(?P<province_id>\d+)/province-photos",
        permission_classes=[permissions.IsAuthenticated],
    )
    def province_photos_standalone(self, request, province_id=None):
        qs = ProvincePhoto.objects.filter(province_id=province_id).order_by("order", "-created_at")
        page = self.paginate_queryset(qs)
        if page is not None:
            ser = ProvincePhotoSerializer(page, many=True, context={"request": request})
            return self.get_paginated_response(ser.data)
        ser = ProvincePhotoSerializer(qs, many=True, context={"request": request})
        return Response(ser.data)
    @extend_schema(
        tags=["Attractions"],
        summary="Province photos",
        description="Returns photos of all attractions in a province. Staff can access any province; non-staff are limited to their own province.",
        responses={200: OpenApiResponse(response=AttractionPhotoSerializer(many=True), description="Province gallery")}
    )
    @action(
        detail=False,
        methods=["get"],
        url_path=r"province/(?P<province_id>\d+)/photos",
        permission_classes=[permissions.IsAuthenticated],
    )
    def province_photos(self, request, province_id=None):
        user = request.user
        if not (user.is_staff or user.is_superuser):
            if getattr(user, "province_id", None) != int(province_id):
                return Response(status=status.HTTP_403_FORBIDDEN)

        qs = AttractionPhoto.objects.filter(attraction__province_id=province_id).select_related("attraction")

        page = self.paginate_queryset(qs)
        if page is not None:
            ser = AttractionPhotoSerializer(page, many=True, context={"request": request})
            return self.get_paginated_response(ser.data)

        ser = AttractionPhotoSerializer(qs, many=True, context={"request": request})
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

    @action(
        detail=True,
        methods=["post"],
        url_path="reviews-my",
        permission_classes=[permissions.IsAuthenticated],
    )
    def create_my_review(self, request, pk=None):
        attraction = self.get_object()
        ser = AttractionReviewCreateSerializer(data=request.data)
        ser.is_valid(raise_exception=True)

        obj = AttractionReview.objects.create(
            attraction=attraction,
            user=request.user,
            rating=ser.validated_data["rating"],
            comment=ser.validated_data.get("comment", "")
        )

        return Response(
            AttractionReviewSerializer(obj, context={"request": request}).data,
            status=status.HTTP_201_CREATED
        )

    @extend_schema(
        tags=["Attractions"],
        summary="Search attractions",
        description="Search by title/short_description/description/venue. Respects user's province filter.",
        responses={200: OpenApiResponse(response=AttractionSearchResultSerializer(many=True), description="Search results")},
    )
    @action(detail=False, methods=["get"], url_path="search", permission_classes=[permissions.IsAuthenticated])
    def search(self, request):
        q = (request.query_params.get("q") or "").strip()
        qs = self.get_queryset().annotate(average_rating=Avg("reviews__rating"))
        if q:
            qs = qs.filter(
                Q(title__icontains=q) |
                Q(short_description__icontains=q) |
                Q(description__icontains=q) |
                Q(venue__icontains=q)
            )
        page = self.paginate_queryset(qs)
        if page is not None:
            ser = AttractionSearchResultSerializer(page, many=True, context={"request": request})
            return self.get_paginated_response(ser.data)
        ser = AttractionSearchResultSerializer(qs, many=True, context={"request": request})
        return Response(ser.data)
    @extend_schema(
        tags=["Attractions"],
        summary="Top 3 attractions of a province by rating",
        description="Returns top 3 attractions of the specified province, ordered by average rating. Staff can access any province; non-staff are limited to their own province.",
        responses={200: OpenApiResponse(response=AttractionSerializer(many=True), description="Top 3 attractions")}
    )
    @action(
        detail=False,
        methods=["get"],
        url_path="top-attractions",
    )
    def top_attractions(self, request):
        province_id = request.query_params.get("province_id")
        if province_id is None:
            return Response({"detail": "province_id required"}, status=400)

        user = request.user
        if not (user.is_staff or user.is_superuser):
            if getattr(user, "province_id", None) != int(province_id):
                return Response(status=403)

        qs = Attraction.objects.filter(province_id=province_id).annotate(
            average_rating=Avg("reviews__rating")
        ).order_by('-average_rating')[:3]

        ser = AttractionSerializer(qs, many=True, context={"request": request})
        return Response(ser.data)

    @extend_schema(
        tags=["Attractions"],
        summary="Top 10 attractions of a province by rating",
        description="Returns top 10 attractions of the specified province, ordered by average rating. Staff can access any province; non-staff are limited to their own province.",
        responses={200: OpenApiResponse(response=AttractionSerializer(many=True), description="Top 10 attractions")}
    )
    @action(
        detail=False,
        methods=["get"],
        url_path="top-10-attractions",
    )
    def top_10_attractions(self, request):
        province_id = request.query_params.get("province_id")
        if province_id is None:
            return Response({"detail": "province_id required"}, status=400)

        user = request.user
        if not (user.is_staff or user.is_superuser):
            if getattr(user, "province_id", None) != int(province_id):
                return Response(status=403)

        qs = Attraction.objects.filter(province_id=province_id).annotate(
            average_rating=Avg("reviews__rating")
        ).order_by('-average_rating')[:10]

        ser = AttractionSerializer(qs, many=True, context={"request": request})
        return Response(ser.data)
