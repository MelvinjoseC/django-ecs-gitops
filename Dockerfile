# =============================================================================
# Stage 1: Build & dependency compilation
# =============================================================================
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# =============================================================================
# Stage 2: Minimal hardened runtime
# =============================================================================
FROM python:3.11-slim AS runner

LABEL org.opencontainers.image.title="django-ecs-gitops" \
      org.opencontainers.image.description="Production Django REST API for AWS ECS Fargate" \
      org.opencontainers.image.authors="MelvinjoseC" \
      org.opencontainers.image.source="https://github.com/MelvinjoseC/django-ecs-gitops"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:${PATH}" \
    PYTHONPATH="/install/lib/python3.11/site-packages:${PYTHONPATH}"

WORKDIR /app

# Install runtime PostgreSQL client library and dumb-init for PID 1 signal forwarding
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# Create restricted non-root system user and group
RUN groupadd -g 10001 appuser && \
    useradd -u 10001 -g appuser -d /app -s /sbin/nologin -M appuser

# Copy installed Python packages and source code
COPY --from=builder /install /install
COPY --chown=appuser:appuser . .

# Collect static assets
RUN python manage.py collectstatic --noinput || true

# Enforce secure ownership and switch user
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# Native Python healthcheck with exit code validation using lightweight liveness probe
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD python -c "import urllib.request, sys; res = urllib.request.urlopen('http://localhost:8000/api/health/live/', timeout=3); sys.exit(0 if res.getcode() == 200 else 1)" || exit 1

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app.core.wsgi:application"]
