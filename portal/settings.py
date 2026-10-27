import os
from pathlib import Path
from django.core.exceptions import ImproperlyConfigured

BASE_DIR = Path(__file__).resolve().parent.parent
DEBUG = os.environ.get('PORTAL_DEBUG', '1') == '1'
SECRET_KEY = os.environ.get('PORTAL_SECRET_KEY') or (
    'django-insecure-local-exam-portal-development-only' if DEBUG else ''
)
if not SECRET_KEY:
    raise ImproperlyConfigured('Set PORTAL_SECRET_KEY when PORTAL_DEBUG=0.')
ALLOWED_HOSTS = os.environ.get('PORTAL_ALLOWED_HOSTS', 'localhost,127.0.0.1,[::1]').split(',')
ROOT_URLCONF = 'portal.urls'
INSTALLED_APPS = ['django.contrib.sessions', 'django.contrib.messages', 'django.contrib.staticfiles', 'portal']
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'portal.security.MemberMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
TEMPLATES = [{
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'APP_DIRS': True,
    'OPTIONS': {'context_processors': [
        'django.template.context_processors.request',
        'django.contrib.messages.context_processors.messages',
        'portal.site.brand_context',
    ]},
}]
DATABASES = {'default': {
    'ENGINE': 'django.db.backends.sqlite3',
    'NAME': os.environ.get('PORTAL_DB', BASE_DIR / 'db.sqlite3'),
    'OPTIONS': {'timeout': 12, 'transaction_mode': 'IMMEDIATE'},
}}
LANGUAGE_CODE = 'ru'
TIME_ZONE = 'Europe/Moscow'
USE_TZ = True
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'collected-static'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = not DEBUG
CSRF_COOKIE_SECURE = not DEBUG
SESSION_COOKIE_AGE = 86400
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
