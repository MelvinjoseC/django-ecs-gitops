from rest_framework.pagination import PageNumberPagination


class StandardResultsSetPagination(PageNumberPagination):
    """
    Production pagination class supporting client-controlled page sizes
    with a strict upper bound to prevent database denial-of-service.
    """

    page_size = 10
    page_size_query_param = "page_size"
    max_page_size = 100
