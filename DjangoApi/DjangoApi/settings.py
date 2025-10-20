from pathlib import Path
import os
from datetime import timedelta
from urllib.parse import urlparse

BASE_DIR = Path(__file__).resolve().parent.parent

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

# ---------- Defaults tuned for LOCAL development (no .env needed) ----------
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
    # Whitenoise only in production (added below if not DEBUG)
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

# Add Whitenoise only when DEBUG is False
if not DEBUG:
    MIDDLEWARE.insert(2, "whitenoise.middleware.WhiteNoiseMiddleware")

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

# Database: default SQLite for local; overrides via DATABASE_URL
DATABASE_URL = env("DATABASE_URL", "")
if DATABASE_URL:
    u = urlparse(DATABASE_URL)
    if u.scheme.startswith("postgres"):
        ENGINE = "django.db.backends.postgresql"
    elif u.scheme.startswith("mysql"):
        ENGINE = "django.db.backends.mysql"
    elif u.scheme.startswith("sqlite"):
        ENGINE = "django.db.backends.sqlite3"
    else:
        ENGINE = "django.db.backends.postgresql"

    DATABASES = {
        "default": {
            "ENGINE": ENGINE,
            "NAME": u.path.lstrip("/") or BASE_DIR / "db.sqlite3",
            "USER": u.username or "",
            "PASSWORD": u.password or "",
            "HOST": u.hostname or "",
            "PORT": u.port or "",
            "CONN_MAX_AGE": env("DB_CONN_MAX_AGE", 60, int),
            "ATOMIC_REQUESTS": True,
        }
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = "Asia/Tehran"
USE_I18N = True
USE_TZ = True

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

# Storage backends: plain in DEBUG, Whitenoise in production
STORAGES = {
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage"
    } if not DEBUG else {
        "BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage"
    },
}

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

# CORS/CSRF defaults for local
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

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
OTP_SETTINGS = {
    "CODE_TTL_SECONDS": 180,
    "RESEND_WINDOW_SECONDS": 60,
    "MAX_REQUESTS_PER_HOUR": 5,   
}