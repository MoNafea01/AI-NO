from django.urls import path
from .views import MyProjectsView, PublicProjectsView, UploadProjectView, UpdateProjectView , DeleteProjectView

urlpatterns = [
    path('my-projects/<str:username>/', MyProjectsView.as_view(), name='my-projects'),
    path('public-projects/<str:username>/', PublicProjectsView.as_view(), name='public-projects'),
    path('upload-project/', UploadProjectView.as_view(), name='upload-project'),
    path('update-project/<int:pk>/', UpdateProjectView.as_view(), name='update-project'),
    path('delete-project/<int:pk>/', DeleteProjectView.as_view(), name='delete-project'),
]