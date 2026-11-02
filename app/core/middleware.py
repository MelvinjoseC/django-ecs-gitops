import logging
import threading
import uuid

_thread_locals = threading.local()


def get_current_request_id():
    """Retrieve the current thread-bound request ID."""
    return getattr(_thread_locals, "request_id", "-")


class RequestIDFilter(logging.Filter):
    """Logging filter that injects the active request_id into every log record."""

    def filter(self, record):
        record.request_id = get_current_request_id()
        return True


class RequestIDMiddleware:
    """
    Middleware that extracts or generates a unique correlation ID (X-Request-ID)
    for each request, binds it to thread-local context for logging, and returns
    it in the response header.
    """

    HEADER_NAME = "HTTP_X_REQUEST_ID"
    RESPONSE_HEADER = "X-Request-ID"

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request_id = request.META.get(self.HEADER_NAME)
        if not request_id:
            request_id = str(uuid.uuid4())

        _thread_locals.request_id = request_id
        request.id = request_id

        try:
            response = self.get_response(request)
        finally:
            _thread_locals.request_id = "-"

        response[self.RESPONSE_HEADER] = request_id
        return response
