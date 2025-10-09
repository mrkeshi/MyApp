from django.db import models
from django.conf import settings
import os, uuid

def attraction_cover_upload_path(instance, filename):
    ext = os.path.splitext(filename)[1]
    pid = instance.province_id or "tmp"
    return f"attractions/covers/{pid}/{uuid.uuid4()}{ext}"

def attraction_photo_upload_path(instance, filename):
    ext = os.path.splitext(filename)[1]
    aid = instance.attraction_id or "tmp"
    return f"attractions/photos/{aid}/{uuid.uuid4()}{ext}"

class Attraction(models.Model):
    province = models.ForeignKey("Province.Province", on_delete=models.CASCADE, related_name="attractions")
    title = models.CharField(max_length=200)
    short_description = models.CharField(max_length=500)
    description = models.TextField()
    registration_cost = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    discount_code = models.CharField(max_length=50, blank=True, default="")
    venue = models.CharField(max_length=255)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    cover_image = models.ImageField(upload_to=attraction_cover_upload_path, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("province_id", "title")

    def __str__(self):
        return self.title

class AttractionPhoto(models.Model):
    attraction = models.ForeignKey(Attraction, on_delete=models.CASCADE, related_name="photos")
    image = models.ImageField(upload_to=attraction_photo_upload_path)
    title = models.CharField(max_length=150, blank=True, default="")
    order = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("order", "-created_at")

    def __str__(self):
        return self.title or f"Photo #{self.pk} of {self.attraction_id}"

class AttractionReview(models.Model):
    attraction = models.ForeignKey(Attraction, on_delete=models.CASCADE, related_name="reviews")
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="attraction_reviews")
    rating = models.PositiveSmallIntegerField()  # 1..5
    comment = models.TextField(blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("-created_at",)
        constraints = [
            models.UniqueConstraint(fields=["attraction", "user"], name="one_review_per_user_per_attraction"),
        ]

    def __str__(self):
        return f"{self.attraction_id}-{self.user_id} ({self.rating})"
