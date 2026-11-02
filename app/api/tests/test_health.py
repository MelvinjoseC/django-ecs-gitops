from unittest.mock import patch

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


class HealthCheckTests(APITestCase):
    def test_health_check_legacy_endpoint(self):
        """Test legacy /api/health/ endpoint returns 200 when database is healthy."""
        url = reverse("health-check")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["status"], "healthy")
        self.assertEqual(response.data["database"], "healthy")

    def test_health_live_endpoint(self):
        """Test shallow /api/health/live/ probe returns 200 OK without database overhead."""
        url = reverse("health-live")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["status"], "healthy")
        self.assertEqual(response.data["probe"], "liveness")
        self.assertIn("timestamp", response.data)

    def test_health_ready_healthy(self):
        """Test deep /api/health/ready/ probe returns 200 and latency when DB is reachable."""
        url = reverse("health-ready")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["status"], "healthy")
        self.assertEqual(response.data["probe"], "readiness")
        self.assertEqual(response.data["database"]["status"], "healthy")
        self.assertGreaterEqual(response.data["database"]["latency_ms"], 0.0)

    @patch("app.api.views.connection.cursor")
    def test_health_ready_unhealthy_db(self, mock_cursor):
        """Test deep /api/health/ready/ probe returns 503 when database is unreachable."""
        mock_cursor.side_effect = Exception("Connection timed out")
        url = reverse("health-ready")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        self.assertEqual(response.data["status"], "unhealthy")
        self.assertIn("unhealthy: Connection timed out", response.data["database"]["status"])

    @patch("app.api.views.connection.cursor")
    def test_health_check_unhealthy_db(self, mock_cursor):
        """Test legacy health check endpoint returns 503 when database is unreachable."""
        mock_cursor.side_effect = Exception("Connection timed out")
        url = reverse("health-check")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        self.assertEqual(response.data["status"], "unhealthy")
        self.assertIn("unhealthy: Connection timed out", response.data["database"])
