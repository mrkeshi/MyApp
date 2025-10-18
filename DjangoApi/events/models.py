from datetime import timezone

from django.db import models

# Create your models here.
from django.db import models
from django.conf import settings
from django.db.models import ExpressionWrapper, F
from django.forms import DurationField


def event_cover_upload_path(instance, filename):
    pid = instance.province_id or "tmp"
    return f"events/covers/{pid}/{filename}"

class EventQuerySet(models.QuerySet):
    def upcoming(self):
        now = timezone.now()
        return self.filter(start_at__gte=now).annotate(
            time_left=ExpressionWrapper(F('start_at') - now, output_field=DurationField())
        ).order_by('time_left')

class Event(models.Model):
    province = models.ForeignKey("Province.Province", on_delete=models.CASCADE, related_name="event")
    title = models.CharField(max_length=200)
    short_description = models.CharField(max_length=500)
    description = models.TextField()
    registration_cost = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    discount_code = models.CharField(max_length=50, blank=True, default="")
    venue = models.CharField(max_length=255)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    cover_image = models.ImageField(upload_to='event_cover_upload_path', null=True, blank=True)
    start_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = EventQuerySet.as_manager()

    class Meta:
        ordering = ("start_at", "province_id")


    def __str__(self):
        return self.title

class EventReview(models.Model):
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name="reviews")
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="event_reviews")
    rating = models.PositiveSmallIntegerField()
    comment = models.TextField(blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("-created_at",)


    def __str__(self):
        return f"{self.event_id} - {self.user_id} ({self.rating})"
