from django.contrib import admin
from .models import Province, ProvincePhoto

class ProvincePhotoInline(admin.TabularInline):
    model = ProvincePhoto
    extra = 1
    fields = ("image", "title", "order")
    classes = ("collapse",)

@admin.register(Province)
class ProvinceAdmin(admin.ModelAdmin):
    list_display = ("id", "name_fa", "name_en", "capital", "population", "area")
    search_fields = ("name_fa", "name_en", "capital")
    list_filter = ("capital",)
    ordering = ("name_fa",)
    fieldsets = (
        (None, {"fields": ("name_fa", "name_en", "capital", "population", "area")}),
        ("Extra info", {"fields": ("description", "map_image")}),
    )
    inlines = [ProvincePhotoInline]

@admin.register(ProvincePhoto)
class ProvincePhotoAdmin(admin.ModelAdmin):
    list_display = ("province", "title", "order", "created_at")
    list_filter = ("province",)
    search_fields = ("title", "province__name_fa", "province__name_en")
    ordering = ("province", "order", "-created_at")
