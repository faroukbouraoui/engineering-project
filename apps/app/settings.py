import os
# Database postgres Docker 
# Docker host : host.docker.internal  or database service name 
# docker inspect cloudapp-django-postgresdb | grep "IPAddress"
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get("POSTGRES_NAME", "DB2"),
        'USER': os.environ.get("POSTGRES_USER", "postgres"),
        'PASSWORD': os.environ.get("POSTGRES_PASSWORD", "postgres"),
        'HOST': os.environ.get("POSTGRES_HOST", "localhost"),
        'PORT': int(os.environ.get("POSTGRES_PORT", "5432")),
    }
}