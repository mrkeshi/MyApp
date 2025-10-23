from pathlib import Path
import os
from datetime import timedelta
from urllib.parse import urlparse
from dotenv import load_dotenv

# ───────────────────────────────────────────────────────────────────────────────
# Paths & .env
# ───────────────────────────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

# ───────────────────────────────────────────────────────────────────────────────
# Helper: env()
# ───────────────────────────────────────────────────────────────────────────────
def env(key, default=None, cast=str):
    val = os.getenv(key, default)
    if val is None:
        return None
    if cast is bool:
        return str(val).lower() in ("1", "true", "yes", "on")
    if cast is int:
        try:
            return int(val)
        except ValueError:
            return default
    return val

# ───────────────────────────────────────────────────────────────────────────────
# Core
# ───────────────────────────────────────────────────────────────────────────────
SECRET_KEY = env("DJANGO_SECRET_KEY", "dev-only-secret-key-change-for-prod")
DEBUG = env("DJANGO_DEBUG", True, bool)

ALLOWED_HOSTS = [h.strip() for h in env(
    "DJANGO_ALLOWED_HOSTS",
    "127.0.0.1,localhost,10.0.2.2"
).split(",") if h.strip()]

CSRF_TRUSTED_ORIGINS = [o.strip() for o in env(
    "DJANGO_CSRF_TRUSTED_ORIGINS",
    "http://127.0.0.1:8000,http://localhost:8000,http://10.0.2.2:8000"
).split(",") if o.strip()]

USE_X_FORWARDED_HOST = env("DJANGO_USE_X_FORWARDED_HOST", False, bool)
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https") if env("DJANGO_HTTPS_BEHIND_PROXY", False, bool) else None

# ───────────────────────────────────────────────────────────────────────────────
# Apps & Middleware
# ───────────────────────────────────────────────────────────────────────────────
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "rest_framework",
    "drf_spectacular",
    "drf_spectacular_sidecar",
    "corsheaders",
    "Province",
    "accounts",
    "events",
    "attractions",
    "bookmarks",
]
AUTH_USER_MODEL = "accounts.User"

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    # بدون WhiteNoise (استاتیک را Nginx سرو می‌کند)
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "DjangoApi.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "DjangoApi.wsgi.application"

# ───────────────────────────────────────────────────────────────────────────────
# Database
# ───────────────────────────────────────────────────────────────────────────────
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}

# ───────────────────────────────────────────────────────────────────────────────
# Auth
# ───────────────────────────────────────────────────────────────────────────────
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# ───────────────────────────────────────────────────────────────────────────────
# i18n / tz
# ───────────────────────────────────────────────────────────────────────────────
LANGUAGE_CODE = "en-us"
TIME_ZONE = "Asia/Tehran"
USE_I18N = True
USE_TZ = True

# ───────────────────────────────────────────────────────────────────────────────
# Static & Media (بدون WhiteNoise)
# ───────────────────────────────────────────────────────────────────────────────
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

STORAGES = {
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
    "staticfiles": {"BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage"},
}

# ───────────────────────────────────────────────────────────────────────────────
# DRF / JWT / Schema
# ───────────────────────────────────────────────────────────────────────────────
REST_FRAMEWORK = {
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
    "DEFAULT_RENDERER_CLASSES": [
        "rest_framework.renderers.JSONRenderer",
    ] if not DEBUG else [
        "rest_framework.renderers.JSONRenderer",
        "rest_framework.renderers.BrowsableAPIRenderer",
    ],
}

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=env("JWT_ACCESS_MINUTES", 60, int)),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=env("JWT_REFRESH_DAYS", 7, int)),
    "AUTH_HEADER_TYPES": ("Bearer",),
}

SPECTACULAR_SETTINGS = {
    "TITLE": "Iran Geo & Tourism API",
    "DESCRIPTION": "API for geographical and tourism data of Iran.",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "SERVERS": [
        {"url": env("OPENAPI_SERVER_PROD", "https://api.penvis.ir"), "description": "Production"},
        {"url": env("OPENAPI_SERVER_STAGING", "https://staging.penvis.ir"), "description": "Staging"},
        {"url": "http://10.0.0.1:8000", "description": "Android Emulator (host)"},
        {"url": "http://127.0.0.1:8000", "description": "Local development"},
    ],
    "SECURITY": [{"BearerAuth": []}],
    "COMPONENTS": {
        "securitySchemes": {
            "BearerAuth": {"type": "http", "scheme": "bearer", "bearerFormat": "JWT"}
        }
    },
}

API_BASE_URL = "api/v1/"

# ───────────────────────────────────────────────────────────────────────────────
# CORS / CSRF
# ───────────────────────────────────────────────────────────────────────────────
CORS_ALLOW_ALL_ORIGINS = env("CORS_ALLOW_ALL_ORIGINS", True, bool)
CORS_ALLOWED_ORIGINS = [o.strip() for o in env("CORS_ALLOWED_ORIGINS", "").split(",") if o.strip()]
CORS_ALLOW_CREDENTIALS = env("CORS_ALLOW_CREDENTIALS", False, bool)

SESSION_COOKIE_SECURE = env("SESSION_COOKIE_SECURE", False, bool)
CSRF_COOKIE_SECURE = env("CSRF_COOKIE_SECURE", False, bool)
SECURE_SSL_REDIRECT = env("SECURE_SSL_REDIRECT", False, bool)
SECURE_HSTS_SECONDS = env("SECURE_HSTS_SECONDS", 0, int) if not DEBUG else 0
SECURE_HSTS_INCLUDE_SUBDOMAINS = env("SECURE_HSTS_INCLUDE_SUBDOMAINS", False, bool)
SECURE_HSTS_PRELOAD = env("SECURE_HSTS_PRELOAD", False, bool)
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = "DENY"
CSRF_COOKIE_HTTPONLY = True
SESSION_COOKIE_HTTPONLY = True

# ───────────────────────────────────────────────────────────────────────────────
# Logging
# ───────────────────────────────────────────────────────────────────────────────
LOG_LEVEL = env("DJANGO_LOG_LEVEL", "INFO")
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {"format": "[{levelname}] {asctime} {name} | {message}", "style": "{"},
    },
    "handlers": {
        "console": {"class": "logging.StreamHandler", "formatter": "verbose"},
    },
    "root": {"handlers": ["console"], "level": LOG_LEVEL},
}

# ───────────────────────────────────────────────────────────────────────────────
# Misc
# ───────────────────────────────────────────────────────────────────────────────
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

OTP_SETTINGS = {
    "CODE_TTL_SECONDS": 180,
    "RESEND_WINDOW_SECONDS": 60,
    "MAX_REQUESTS_PER_HOUR": 5,
}
