from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone
from django.core.validators import RegexValidator

import Province.models


class User(AbstractUser):
    phone_number = models.CharField(
        max_length=20, unique=True, null=True, blank=True,
        validators=[RegexValidator(regex=r'^\+?[0-9]{8,20}$', message="Phone number must be 8-20 digits, optional leading +")]
    )
    profile_image = models.ImageField(upload_to="profiles/", null=True, blank=True)
    province = models.ForeignKey(Province.models.Province, on_delete=models.SET_NULL, null=True, blank=True, related_name="users")


class PhoneOTP(models.Model):
    phone_number = models.CharField(max_length=20, db_index=True)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    class Meta:
        indexes = [
            models.Index(fields=["phone_number", "is_used"]),
        ]

    def is_expired(self):
        return timezone.now() > self.expires_at
