import uuid

from django.test import TestCase
from django.urls import reverse
from rest_framework import status

from app.core.middleware import get_current_request_id


class RequestIDMiddlewareTests(TestCase):
    def test_request_id_generated_when_missing(self):
        """Verify middleware generates a UUID when X-Request-ID header is not provided."""
        response = self.client.get(reverse("health-live"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("X-Request-ID", response.headers)
        val = response.headers["X-Request-ID"]
        # Must be valid UUID
        parsed = uuid.UUID(val)
        self.assertEqual(str(parsed), val)

    def test_request_id_preserved_when_provided(self):
        """Verify middleware preserves incoming X-Request-ID header."""
        custom_id = "test-custom-tracing-id-12345"
        response = self.client.get(reverse("health-live"), HTTP_X_REQUEST_ID=custom_id)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.headers.get("X-Request-ID"), custom_id)

    def test_thread_local_cleaned_up_after_request(self):
        """Verify thread-local request ID resets to default placeholder after response cycle."""
        self.client.get(reverse("health-live"))
        self.assertEqual(get_current_request_id(), "-")
