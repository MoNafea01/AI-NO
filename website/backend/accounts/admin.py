from django.contrib import admin
from .models import User , Profile, Post, Topic, Comment
# Register your models here.


class UserAdmin(admin.ModelAdmin):
    list_display = ['username', 'email']


class ProfileAdmin(admin.ModelAdmin):
    list_editable = ['verified']
    list_display = ['user', 'full_name','verified']



admin.site.register(User, UserAdmin)
admin.site.register( Profile,ProfileAdmin)
admin.site.register(Post)
admin.site.register(Topic)
admin.site.register(Comment)
