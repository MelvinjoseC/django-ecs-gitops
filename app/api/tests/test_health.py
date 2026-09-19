from unittest.mock import patch

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


class HealthCheckTests(APITestCase):
    def test_health_check_healthy(self):
        """Test the healthcheck endpoint returns 200 when the database is healthy."""
        url = reverse("health-check")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["status"], "healthy")
        self.assertEqual(response.data["database"], "healthy")

    @patch("app.api.views.connection.cursor")
    def test_health_check_unhealthy_db(self, mock_cursor):
        """Test the healthcheck endpoint returns 503 when the database is unreachable."""
        mock_cursor.side_effect = Exception("Connection timed out")
        url = reverse("health-check")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        self.assertEqual(response.data["status"], "unhealthy")
        self.assertIn("unhealthy: Connection timed out", response.data["database"])
