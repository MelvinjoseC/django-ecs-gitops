from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import TaskViewSet, health_check

router = DefaultRouter()
router.register(r"tasks", TaskViewSet)

urlpatterns = [
    path("health/", health_check, name="health-check"),
] + router.urls
