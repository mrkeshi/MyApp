from django.urls import path
from Province.views import CustomTokenRefreshView
from .views import RequestCodeView, VerifyCodeView, MeView

urlpatterns = [
    path("auth/request-code/", RequestCodeView.as_view(), name="auth-request-code"),
    path("auth/verify-code/",  VerifyCodeView.as_view(),  name="auth-verify-code"),
    path("auth/refresh/", CustomTokenRefreshView.as_view(), name="auth-refresh"),
    path("me/", MeView.as_view(), name="me"),
]
