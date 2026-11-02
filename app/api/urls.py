from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import TaskViewSet, health_check, health_live, health_ready

router = DefaultRouter()
router.register(r"tasks", TaskViewSet)

urlpatterns = [
    path("health/", health_check, name="health-check"),
    path("health/live/", health_live, name="health-live"),
    path("health/ready/", health_ready, name="health-ready"),
] + router.urls
