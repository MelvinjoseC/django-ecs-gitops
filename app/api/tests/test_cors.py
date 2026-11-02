from django.test import TestCase, override_settings
from django.urls import reverse
from rest_framework import status


class CORSTests(TestCase):
    @override_settings(
        CORS_ALLOW_ALL_ORIGINS=False,
        CORS_ALLOWED_ORIGINS=["https://example.com"],
    )
    def test_cors_preflight_allowed_origin(self):
        """Verify OPTIONS preflight request for allowed origin returns 200 and access headers."""
        response = self.client.options(
            reverse("health-live"),
            HTTP_ORIGIN="https://example.com",
            HTTP_ACCESS_CONTROL_REQUEST_METHOD="GET",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.headers.get("Access-Control-Allow-Origin"), "https://example.com"
        )

    @override_settings(
        CORS_ALLOW_ALL_ORIGINS=False,
        CORS_ALLOWED_ORIGINS=["https://trusted.com"],
    )
    def test_cors_untrusted_origin_rejected(self):
        """Verify unauthorized origin does not receive Access-Control-Allow-Origin."""
        response = self.client.get(
            reverse("health-live"),
            HTTP_ORIGIN="https://evil.com",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertNotIn("Access-Control-Allow-Origin", response.headers)
