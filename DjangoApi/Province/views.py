from django.shortcuts import render
from rest_framework import viewsets, mixins
from drf_spectacular.utils import extend_schema, OpenApiResponse
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenRefreshView

from .models import Province
from .serializers import ProvinceSerializer, ProvincePhotoSerializer


@extend_schema(
    tags=["Provinces"],
    summary="List all provinces",
    description="Returns the list of all Iranian provinces.",
    responses={200: OpenApiResponse(response=ProvinceSerializer(many=True), description="Province list")}
)
class ProvinceViewSet(mixins.ListModelMixin,
                      mixins.RetrieveModelMixin,
                      viewsets.GenericViewSet):
    queryset = Province.objects.all()
    serializer_class = ProvinceSerializer
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Provinces"],
        summary="Retrieve a province",
        description="Retrieve a single province by database id.",
        responses={200: ProvinceSerializer}
    )
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)

    @extend_schema(
        tags=["Provinces"],
        summary="List province photos",
        description="Returns photo gallery for a province.",
        responses={200: OpenApiResponse(response=ProvincePhotoSerializer(many=True), description="Province photos")}
    )
    @action(detail=True, methods=["get"], url_path="photos")
    def photos(self, request, pk=None):
        province = self.get_object()
        qs = province.photos.filter(is_published=True)
        ser = ProvincePhotoSerializer(qs, many=True, context={"request": request})
        return Response(ser.data)
