from rest_framework.routers import DefaultRouter
from events.views import EventViewSet

router = DefaultRouter()
# ... قبلی‌ها
router.register(r"events", EventViewSet, basename="events")
urlpatterns = router.urls
