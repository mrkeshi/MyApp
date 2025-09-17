from rest_framework.routers import DefaultRouter

from attractions.views import AttractionViewSet


router = DefaultRouter()
router.register(r"attractions", AttractionViewSet, basename="attractions")
urlpatterns = router.urls
