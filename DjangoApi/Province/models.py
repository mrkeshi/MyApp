from django.db import models


def province_map_upload_path(instance, filename):
    return f"provinces/maps/{instance.id or 'tmp'}/{filename}"


class Province(models.Model):
    name_fa = models.CharField("Persian name", max_length=100, unique=True)
    name_en = models.CharField("English name", max_length=100, blank=True, default="")
    capital = models.CharField("Capital city", max_length=100, blank=True, default="")
    population = models.CharField("Population", null=True, blank=True)
    area = models.CharField("Area (km², string)", max_length=50, blank=True, default="")
    description = models.TextField("Description", blank=True, default="")
    map_image = models.ImageField("Map image", upload_to=province_map_upload_path, null=True, blank=True)

    class Meta:
        verbose_name = "Province"
        verbose_name_plural = "Provinces"
        ordering = ("name_fa",)

    def __str__(self):
        return self.name_en
