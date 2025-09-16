from django.shortcuts import render
from rest_framework import viewsets, mixins
from drf_spectacular.utils import extend_schema, OpenApiResponse
from .models import Province
from .serializers import ProvinceSerializer

@extend_schema(
    tags=["Provinces"],
    summary="List all provinces",
    description="Returns the list of all Iranian provinces.",
    responses={200: OpenApiResponse(response=ProvinceSerializer(many=True), description="Province list")}
)
class ProvinceViewSet(mixins.ListModelMixin,
                      mixins.RetrieveModelMixin,
                      viewsets.GenericViewSet):
    """
    GET /api/v1/provinces/      -> list all provinces
    GET /api/v1/provinces/{id}/ -> retrieve a province by id
    """
    queryset = Province.objects.all()
    serializer_class = ProvinceSerializer

    @extend_schema(
        tags=["Provinces"],
        summary="Retrieve a province",
        description="Retrieve a single province by database id.",
        responses={200: ProvinceSerializer}
    )
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)
