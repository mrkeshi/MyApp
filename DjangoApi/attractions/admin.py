from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import Attraction, AttractionPhoto, AttractionReview

class AttractionPhotoInline(admin.TabularInline):
    model = AttractionPhoto
    extra = 1
    fields = ("image", "title", "order")
    classes = ("collapse",)

class AttractionReviewInline(admin.TabularInline):
    model = AttractionReview
    extra = 0
    fields = ("user", "rating", "comment")
    readonly_fields = ("user",)

@admin.register(Attraction)
class AttractionAdmin(admin.ModelAdmin):
    list_display = ("id", "province", "title")
    search_fields = ("title", "province__name_fa", "province__name_en", "venue")
    list_filter = ("province",)
    fieldsets = (
        (None, {"fields": ("province", "title", "short_description", "description", "cover_image")}),
        ("Venue", {"fields": ("venue", "latitude", "longitude")}),
        ("Registration (optional)", {"fields": ("registration_cost", "discount_code")}),
    )
    inlines = [AttractionPhotoInline, AttractionReviewInline]

@admin.register(AttractionPhoto)
class AttractionPhotoAdmin(admin.ModelAdmin):
    list_display = ("attraction", "title", "order", "created_at")
    list_filter = ("attraction",)
    search_fields = ("title", "attraction__title")
    ordering = ("attraction", "order", "-created_at")

@admin.register(AttractionReview)
class AttractionReviewAdmin(admin.ModelAdmin):
    list_display = ("attraction", "user", "rating", "created_at")
    list_filter = ("rating", "created_at")
    search_fields = ("attraction__title", "user__username", "comment")
