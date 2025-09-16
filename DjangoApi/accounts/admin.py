from django.contrib import admin

# Register your models here.
# accounts/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.html import format_html
from .models import User, PhoneOTP

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    fieldsets = BaseUserAdmin.fieldsets + (
        ("Extra", {"fields": ("phone_number", "profile_image", "province")}),
    )
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ("Extra", {"fields": ("phone_number", "profile_image", "province")}),
    )
    list_display = ("username", "phone_number", "first_name", "last_name", "province", "show_img", "is_staff", "is_superuser")
    list_filter = ("is_staff", "is_superuser", "province")
    search_fields = ("username", "phone_number", "first_name", "last_name", "email")
    ordering = ("username",)

    def show_img(self, obj):
        if obj.profile_image:
            return format_html('<img src="{}" width="40" height="40" style="object-fit:cover;border-radius:4px" />', obj.profile_image.url)
        return "-"
    show_img.short_description = "Avatar"

@admin.register(PhoneOTP)
class PhoneOTPAdmin(admin.ModelAdmin):
    list_display = ("phone_number", "code", "is_used", "expires_at", "created_at")
    list_filter = ("is_used",)
    search_fields = ("phone_number", "code")
    readonly_fields = ("created_at",)
    ordering = ("-created_at",)
