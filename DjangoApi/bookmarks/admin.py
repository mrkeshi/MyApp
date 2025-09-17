from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import Bookmark

@admin.register(Bookmark)
class BookmarkAdmin(admin.ModelAdmin):
    list_display = ("user", "content_type", "object_id", "created_at")
    list_filter = ("content_type",)
    search_fields = ("user__username", "user__phone_number")
    ordering = ("-created_at",)
