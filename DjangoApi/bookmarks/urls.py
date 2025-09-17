from bookmarks.views import ToggleBookmarkView, ListBookmarksView
from django.urls import path, include

urlpatterns = [
    path("api/v1/bookmarks/toggle/", ToggleBookmarkView.as_view(), name="bookmarks-toggle"),
    path("api/v1/bookmarks/",        ListBookmarksView.as_view(),   name="bookmarks-list"),
]
