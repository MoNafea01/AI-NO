from rest_framework import serializers
from .models import BlogPost

class BlogPostListSerializer(serializers.ModelSerializer):
    #author: if implemented
    class Meta:
        model = BlogPost
        fields = ['id','title', 'slug' ,'description', 'published_at', 'created_at']
        
class BlogPostDetailSerializer(serializers.ModelSerializer):
    #author: if implemented
    
    class Meta:
        model = BlogPost
        fields = ['id', 'slug', 'title', 'content', 'published_at', 'created_at', 'updated_at']