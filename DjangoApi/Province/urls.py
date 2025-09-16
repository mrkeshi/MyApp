from rest_framework.routers import SimpleRouter

from Province.views import ProvinceViewSet

router = SimpleRouter()
router.register(r'provinces', ProvinceViewSet, basename='province')

urlpatterns = router.urls