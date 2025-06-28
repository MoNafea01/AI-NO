from django.urls import path
from . import views

urlpatterns = [
    path('', views.BlogPostListAPIView.as_view(), name='blog-list'),
    path('<slug:slug>/', views.BlogPostDetailAPIView.as_view(), name='blog-detail'),
]
