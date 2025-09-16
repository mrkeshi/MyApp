from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import Event, EventReview

class EventReviewInline(admin.TabularInline):
    model = EventReview
    extra = 1
    fields = ("user", "rating", "comment")

@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = ("id", "province", "title", "start_at")
    search_fields = ("title", "province__name_fa", "province__name_en", "venue")
    list_filter = ("start_at",)
    inlines = [EventReviewInline]

    fieldsets = (
        (None, {
            "fields": (
                "province", "title", "short_description", "description",
                "cover_image", "start_at", "venue"
            )
        }),
        ("Geo Location", {
            "fields": ("latitude", "longitude"),
            "description": "Enter latitude & longitude for map navigation"
        }),
        ("Extra", {
            "fields": ("registration_cost", "discount_code"),
        }),
    )

@admin.register(EventReview)
class EventReviewAdmin(admin.ModelAdmin):
    list_display = ("event", "user", "rating", "created_at")
    list_filter = ("rating", "created_at")
    search_fields = ("event__title", "user__username", "comment")
