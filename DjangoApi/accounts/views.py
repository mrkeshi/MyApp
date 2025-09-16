import random
from datetime import timedelta
from django.conf import settings
from django.utils import timezone
from django.contrib.auth import get_user_model
from rest_framework import status, generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema, OpenApiResponse
from rest_framework_simplejwt.views import TokenRefreshView

from .models import PhoneOTP
from .serializers import RequestCodeSerializer, VerifyCodeSerializer, MeSerializer, ChangeProvinceSerializer

User = get_user_model()

def _generate_code():
    return f"{random.randint(100000, 999999)}"

def _unique_username_from_phone(phone):
    base = "user_" + phone.replace("+","")[-8:]
    username = base
    i = 1
    while User.objects.filter(username=username).exists():
        i += 1
        username = f"{base}_{i}"
    return username

@extend_schema(
    tags=["Auth"],
    summary="Request OTP code",
    description="Send OTP to the given phone (prints in console for now).",
    request=RequestCodeSerializer,
    responses={200: OpenApiResponse(response=None, description="Code requested")},
)
class RequestCodeView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        ser = RequestCodeSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        phone = ser.validated_data["phone_number"].replace(" ", "").replace("-", "")
        now = timezone.now()

        resend_window = settings.OTP_SETTINGS["RESEND_WINDOW_SECONDS"]
        code_ttl = settings.OTP_SETTINGS["CODE_TTL_SECONDS"]

        recent = PhoneOTP.objects.filter(
            phone_number=phone,
            created_at__gt=now - timedelta(seconds=resend_window)
        ).order_by("-created_at").first()

        if recent:
            retry_at = recent.created_at + timedelta(seconds=resend_window)
            retry_in = max(0, int((retry_at - now).total_seconds()))
            headers = {"Retry-After": str(retry_in)}
            return Response(
                {
                    "detail": "Too many requests. Please wait before requesting a new code.",
                    "next_allowed_at": retry_at.isoformat(),
                    "retry_in_seconds": retry_in,
                },
                status=status.HTTP_429_TOO_MANY_REQUESTS,
                headers=headers
            )

        active_otp = PhoneOTP.objects.filter(
            phone_number=phone, is_used=False, expires_at__gt=now
        ).order_by("-created_at").first()

        if active_otp:
            print(f"[OTP-REUSE] phone={phone} code={active_otp.code} expires_at={active_otp.expires_at.isoformat()}")
            return Response(
                {
                    "detail": "Existing OTP is still valid.",
                    "expires_at": active_otp.expires_at.isoformat()
                },
                status=status.HTTP_200_OK
            )

        code = _generate_code()
        expires_at = now + timedelta(seconds=code_ttl)
        PhoneOTP.objects.create(phone_number=phone, code=code, expires_at=expires_at)

        print(f"[OTP] phone={phone} code={code} expires_at={expires_at.isoformat()}")

        next_allowed_at = now + timedelta(seconds=resend_window)
        return Response(
            {
                "detail": "OTP generated. Check console in dev.",
                "expires_at": expires_at.isoformat(),
                "next_allowed_at": next_allowed_at.isoformat(),
            },
            status=status.HTTP_200_OK
        )

@extend_schema(
    tags=["Auth"],
    summary="Verify OTP and get JWT",
    description="Verify the code, auto-create user if needed, return JWT pair.",
    request=VerifyCodeSerializer,
    responses={200: OpenApiResponse(response=None, description="JWT tokens and user info")},
)
class VerifyCodeView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        ser = VerifyCodeSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        phone = ser.validated_data["phone_number"].replace(" ","").replace("-","")
        otp = ser.validated_data["otp_obj"]

        user, created = User.objects.get_or_create(phone_number=phone, defaults={
            "username": _unique_username_from_phone(phone),
        })
        if created:
            user.set_unusable_password()

        fn = ser.validated_data.get("first_name")
        ln = ser.validated_data.get("last_name")
        province_id = ser.validated_data.get("province_id")
        if fn is not None:
            user.first_name = fn
        if ln is not None:
            user.last_name = ln
        if province_id is not None:
            from Province.models import Province
            try:
                user.province = Province.objects.get(pk=province_id)
            except Province.DoesNotExist:
                pass
        user.save()

        PhoneOTP.objects.filter(phone_number=phone, is_used=False).update(is_used=True)
        PhoneOTP.objects.filter(phone_number=phone, created_at__lt=timezone.now()-timedelta(days=1)).delete()

        refresh = RefreshToken.for_user(user)
        access = str(refresh.access_token)

        me = MeSerializer(user, context={"request": request}).data
        return Response({
            "access": access,
            "refresh": str(refresh),
            "user": me
        }, status=status.HTTP_200_OK)

@extend_schema(
    tags=["Me"],
    summary="Get my profile",
    responses={200: MeSerializer}
)
class MeView(generics.RetrieveUpdateAPIView):
    serializer_class = MeSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_object(self):
        return self.request.user

    @extend_schema(
        tags=["Me"],
        summary="Update my profile",
        request=MeSerializer,
        responses={200: MeSerializer}
    )
    def patch(self, request, *args, **kwargs):
        return super().patch(request, *args, **kwargs)
class ChangeProvinceView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=["Me"],
        summary="Change my province",
        request=ChangeProvinceSerializer,
        responses={200: OpenApiResponse(response=MeSerializer, description="Province updated")}
    )
    def post(self, request):
        ser = ChangeProvinceSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        province_id = ser.validated_data["province_id"]

        from Province.models import Province
        province = Province.objects.get(pk=province_id)

        user = request.user
        user.province = province
        user.save()

        return Response(MeSerializer(user, context={"request": request}).data, status=status.HTTP_200_OK)

class CustomTokenRefreshView(TokenRefreshView):
    @extend_schema(tags=["Auth"], summary="Refresh JWT token")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)