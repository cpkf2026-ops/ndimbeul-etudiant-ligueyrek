"""Pagination des listes (opportunités, actualités), au format attendu par Laravel."""
from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response


class PaginationIA(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'par_page'
    max_page_size = 50

    def get_paginated_response(self, data):
        return Response({
            'total': self.page.paginator.count,
            'page': self.page.number,
            'nb_pages': self.page.paginator.num_pages,
            'par_page': self.get_page_size(self.request),
            'resultats': data,
        })
