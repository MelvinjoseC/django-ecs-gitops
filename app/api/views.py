from rest_framework import viewsets, filters, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.db import connection
from .models import Task
from .serializers import TaskSerializer

class TaskViewSet(viewsets.ModelViewSet):
    queryset         = Task.objects.all()
    serializer_class = TaskSerializer
    filter_backends  = [filters.SearchFilter, filters.OrderingFilter]
    search_fields    = ["title", "description", "status"]
    ordering_fields  = ["created_at", "status"]


@api_view(["GET"])
@permission_classes([AllowAny])
def health_check(request):
    health_status = {
        "status": "healthy",
        "database": "healthy",
    }
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1;")
    except Exception as e:
        health_status["status"] = "unhealthy"
        health_status["database"] = f"unhealthy: {str(e)}"
        return Response(health_status, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    return Response(health_status, status=status.HTTP_200_OK)
