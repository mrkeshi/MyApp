from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import Province


@admin.register(Province)
class ProvinceAdmin(admin.ModelAdmin):
    list_display = ("id", "name_fa", "name_en", "capital", "population", "area")
    search_fields = ("name_fa", "name_en", "capital")
    list_filter = ("capital",)
    ordering = ("name_fa",)

    fieldsets = (
        (None, {
            "fields": ("name_fa", "name_en", "capital", "population", "area")
        }),
        ("Extra info", {
            "fields": ("description", "map_image"),
        }),
    )
