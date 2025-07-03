from django.shortcuts import render
from rest_framework import generics
from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from .models import BlogPost
from .serializers import (BlogPostListSerializer,
    BlogPostDetailSerializer,)
# Create your views here.

class BlogPostListAPIView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = BlogPostListSerializer
    
    
    def get_queryset(self):
        return BlogPost.objects.filter(is_published=True).order_by('-published_at')
    
    
    def get_opration_id(self):
        return "blogpost_list"
    
    
class BlogPostDetailAPIView(generics.RetrieveAPIView):
    permission_classes = [AllowAny]
    serializer_class = BlogPostDetailSerializer
    lookup_field = 'slug'
    
    
    def get_queryset(self):
        return BlogPost.objects.filter(is_published=True)
    
    
    def get_opration_id(self):
        return "blogpost_detail"