from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from .models import PROJECTS
from .serializers import ProjectSerializer
from django.shortcuts import get_object_or_404


# return user projects
class MyProjectsView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, username):
        if request.user.username != username:
            return Response({"detail": "Unauthorized"}, status=status.HTTP_403_FORBIDDEN)
        projects = PROJECTS.objects.filter(owner=request.user)
        serializer = ProjectSerializer(projects, many=True)
        return Response(serializer.data)


# return other users projects ( public projects )
class PublicProjectsView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, username):
        projects = PROJECTS.objects.filter(owner__username=username, option='public')
        serializer = ProjectSerializer(projects, many=True)
        return Response(serializer.data)


# upload project
class UploadProjectView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request):
        serializer = ProjectSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(owner=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# update user project
class UpdateProjectView(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, request, pk):
        project = get_object_or_404(PROJECTS, pk=pk)
        if project.owner != request.user:
            return Response({'detail': 'Not allowed'}, status=status.HTTP_403_FORBIDDEN)
        serializer = ProjectSerializer(project, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# delete project
class DeleteProjectView(APIView):
    permission_classes = [IsAuthenticated]
    def delete(self, request, pk):
        project = get_object_or_404(PROJECTS, pk=pk)
        if project.owner != request.user:
            return Response({'detail': 'Not allowed'}, status=status.HTTP_403_FORBIDDEN)
        project.delete()
        return Response({'detail': 'Project deleted successfully'}, status=status.HTTP_204_NO_CONTENT)