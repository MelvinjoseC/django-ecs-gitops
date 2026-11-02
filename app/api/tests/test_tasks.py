from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient
from app.api.models import Task


class TaskAPITestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.task = Task.objects.create(
            title="Test task",
            description="A test task",
            status="todo",
        )

    def test_list_tasks(self):
        url = reverse("task-list")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_create_task(self):
        url = reverse("task-list")
        data = {"title": "New task", "description": "Desc", "status": "todo"}
        response = self.client.post(url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Task.objects.count(), 2)

    def test_update_task_status(self):
        url = reverse("task-detail", args=[self.task.id])
        response = self.client.patch(url, {"status": "done"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.task.refresh_from_db()
        self.assertEqual(self.task.status, "done")

    def test_delete_task(self):
        url = reverse("task-detail", args=[self.task.id])
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(Task.objects.count(), 0)

    def test_search_task(self):
        url = reverse("task-list") + "?search=Test"
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreater(len(response.data["results"]), 0)

    def test_custom_page_size_pagination(self):
        """Verify client can specify custom page_size within configured limit."""
        for i in range(15):
            Task.objects.create(title=f"Task {i}", status="todo")
        url = reverse("task-list") + "?page_size=5"
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data["results"]), 5)
        self.assertIn("next", response.data)

    def test_ordering_tasks(self):
        """Verify ordering tasks by creation time."""
        url = reverse("task-list") + "?ordering=-created_at"
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
