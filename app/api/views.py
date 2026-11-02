import time

from django.db import connection
from rest_framework import filters, status, viewsets
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from .models import Task
from .pagination import StandardResultsSetPagination
from .serializers import TaskSerializer


class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    pagination_class = StandardResultsSetPagination
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "description", "status"]
    ordering_fields = ["created_at", "status"]


@api_view(["GET"])
@permission_classes([AllowAny])
@throttle_classes([])
def health_live(request):
    """
    Shallow liveness probe for ECS container checks and load balancer process monitoring.
    Verifies that the web process is running and accepting HTTP connections.
    """
    return Response(
        {
            "status": "healthy",
            "probe": "liveness",
            "timestamp": time.time(),
        },
        status=status.HTTP_200_OK,
    )


@api_view(["GET"])
@permission_classes([AllowAny])
@throttle_classes([])
def health_ready(request):
    """
    Deep readiness probe for traffic routing verification.
    Validates database connectivity, measures query round-trip latency, and dependency health.
    """
    health_status = {
        "status": "healthy",
        "probe": "readiness",
        "database": {
            "status": "healthy",
            "latency_ms": 0.0,
        },
    }

    start_time = time.perf_counter()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1;")
            cursor.fetchone()
        latency = (time.perf_counter() - start_time) * 1000
        health_status["database"]["latency_ms"] = round(latency, 2)
    except Exception as e:
        health_status["status"] = "unhealthy"
        health_status["database"]["status"] = f"unhealthy: {str(e)}"
        return Response(health_status, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    return Response(health_status, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([AllowAny])
@throttle_classes([])
def health_check(request):
    """
    Legacy backwards-compatible endpoint maintaining compatibility with ALB target group checks.
    """
    health_status = {
        "status": "healthy",
        "database": "healthy",
    }
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1;")
            cursor.fetchone()
    except Exception as e:
        health_status["status"] = "unhealthy"
        health_status["database"] = f"unhealthy: {str(e)}"
        return Response(health_status, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    return Response(health_status, status=status.HTTP_200_OK)
