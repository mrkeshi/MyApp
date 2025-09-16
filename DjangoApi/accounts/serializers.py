from rest_framework import serializers
from django.utils import timezone
from django.contrib.auth import get_user_model

from Province.models import Province
from .models import PhoneOTP


User = get_user_model()

class RequestCodeSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20)

    def validate_phone_number(self, v):
        v = v.strip()
        v = v.replace(" ", "").replace("-", "")
        if not v.startswith("+") and not v.isdigit():
            raise serializers.ValidationError("Invalid phone number")
        if len(v.replace("+","")) < 8:
            raise serializers.ValidationError("Phone number too short")
        return v

class VerifyCodeSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20)
    code = serializers.CharField(max_length=6)

    province_id = serializers.IntegerField(required=False)

    def validate(self, data):
        phone = data["phone_number"].strip().replace(" ","").replace("-","")
        code = data["code"].strip()
        otp_qs = PhoneOTP.objects.filter(phone_number=phone, is_used=False).order_by("-created_at")
        if not otp_qs.exists():
            raise serializers.ValidationError({"code": "No code requested or already used."})
        otp = otp_qs.first()
        if otp.is_expired():
            raise serializers.ValidationError({"code": "Code expired."})
        if otp.code != code:
            raise serializers.ValidationError({"code": "Invalid code."})
        data["otp_obj"] = otp
        return data

class ProvinceNestedSerializer(serializers.ModelSerializer):
    class Meta:
        model = Province
        fields = ("id", "name_fa", "name_en")

class MeSerializer(serializers.ModelSerializer):
    province = serializers.PrimaryKeyRelatedField(queryset=Province.objects.all(), required=False, allow_null=True)
    province_detail = ProvinceNestedSerializer(source="province", read_only=True)

    class Meta:
        model = User
        fields = ("id", "username", "phone_number", "first_name", "last_name", "profile_image", "province", "province_detail")
        read_only_fields = ("id", "username", "phone_number")


class ChangeProvinceSerializer(serializers.Serializer):
    province_id = serializers.IntegerField()

    def validate_province_id(self, value):
        from Province.models import Province
        try:
            Province.objects.get(pk=value)
        except Province.DoesNotExist:
            raise serializers.ValidationError("Invalid province id")
        return value