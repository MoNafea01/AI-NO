from django.contrib import admin

from .models import BlogPost

# Register your models here.
admin.site.register(BlogPost)

class BlogPostAdmin(admin.ModelAdmin):
    list_display = ('title', 'is_published', 'published_at')
    list_filter = ('is_published')
    search_fields = ('title', 'content')
    prepopulated_fields = {'slug': ('title,')}
    readonly_fields = ('created_at', 'updated_at')
    
    def save_model(self, request, obj, form, change):
        # author configs if added later
        super().save_model(request, obj, form, change)