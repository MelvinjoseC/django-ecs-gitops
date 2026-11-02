from django.test import TestCase
from django.urls import reverse
from rest_framework import status


class OpenAPIDocumentationTests(TestCase):
    def test_schema_endpoint_generates_valid_openapi(self):
        """Verify OpenAPI JSON/YAML schema is generated with HTTP 200 OK."""
        response = self.client.get(reverse("schema"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("openapi", response.content.decode("utf-8").lower())
        self.assertIn("django ecs gitops api", response.content.decode("utf-8").lower())

    def test_swagger_ui_endpoint(self):
        """Verify Swagger UI documentation renders properly."""
        response = self.client.get(reverse("swagger-ui"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("swagger-ui", response.content.decode("utf-8").lower())

    def test_redoc_ui_endpoint(self):
        """Verify Redoc documentation interface renders properly."""
        response = self.client.get(reverse("redoc"))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("redoc", response.content.decode("utf-8").lower())
