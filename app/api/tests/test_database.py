from django.conf import settings
from django.test import TestCase


class DatabaseConfigurationTests(TestCase):
    def test_database_connection_health_checks_enabled(self):
        """Verify CONN_HEALTH_CHECKS is enabled to prevent stale connections in ECS tasks."""
        default_db = settings.DATABASES["default"]
        self.assertTrue(default_db.get("CONN_HEALTH_CHECKS", False))

    def test_timezone_settings_configured(self):
        """Verify timezone support is active and set to UTC."""
        self.assertTrue(settings.USE_TZ)
        self.assertEqual(settings.TIME_ZONE, "UTC")
