from django.db import models

# Create your models here.
from django.db import models
from django.conf import settings

def event_cover_upload_path(instance, filename):
    pid = instance.province_id or "tmp"
    return f"events/covers/{pid}/{filename}"

class Event(models.Model):
    province = models.OneToOneField("Province.Province", on_delete=models.CASCADE, related_name="event")
    title = models.CharField(max_length=200)
    short_description = models.CharField(max_length=500)
    description = models.TextField()
    registration_cost = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    discount_code = models.CharField(max_length=50, blank=True, default="")
    venue = models.CharField(max_length=255)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    cover_image = models.ImageField(upload_to=event_cover_upload_path, null=True, blank=True)
    start_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("start_at", "province_id")

    def __str__(self):
        return self.title

class EventReview(models.Model):
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name="reviews")
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="event_reviews")
    rating = models.PositiveSmallIntegerField()  # 1..5
    comment = models.TextField(blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("-created_at",)
        constraints = [
            models.UniqueConstraint(fields=["event", "user"], name="one_review_per_user_per_event"),
        ]

    def __str__(self):
        return f"{self.event_id} - {self.user_id} ({self.rating})"
