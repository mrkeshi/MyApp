from bookmarks.views import ToggleBookmarkView, ListBookmarksView
from django.urls import path, include

urlpatterns = [
    path("bookmarks/toggle/", ToggleBookmarkView.as_view(), name="bookmarks-toggle"),
    path("bookmarks/",        ListBookmarksView.as_view(),   name="bookmarks-list"),
]
