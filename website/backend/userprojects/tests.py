# for testing => python manage.py test userprojects

from django.urls import reverse
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from .models import PROJECTS
from django.core.files.uploadedfile import SimpleUploadedFile
import io

User = get_user_model()

class ProjectAPITestCase(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@example.com",
            username="testuser",
            password="password123",
            first_name="Test",
            last_name="User"
        )
        self.other_user = User.objects.create_user(
            email="other@example.com",
            username="otheruser",
            password="password123",
            first_name="Other",
            last_name="User"
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

        self.project = PROJECTS.objects.create(
            owner=self.user,
            option='private',
            model='Model1',
            dataset='Dataset1',
            description='Test project',
        )

    def test_upload_project(self):
        url = reverse('upload-project')
        dummy_file = SimpleUploadedFile("test.json", b"{\"test\": true}", content_type="application/json")
        data = {
            "option": "public",
            "model": "TestModel",
            "dataset": "TestDataset",
            "description": "Uploading a project",
            "file": dummy_file
        }
        response = self.client.post(url, data, format='multipart')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['description'], "Uploading a project")

    def test_my_projects_view(self):
        url = reverse('my-projects', kwargs={"username": self.user.username})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_my_projects_unauthorized(self):
        url = reverse('my-projects', kwargs={"username": self.other_user.username})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_public_projects_view(self):
        PROJECTS.objects.create(
            owner=self.other_user,
            option='public',
            model='X',
            dataset='Y',
            description='Public project',
        )
        url = reverse('public-projects', kwargs={"username": self.other_user.username})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_update_project(self):
        url = reverse('update-project', kwargs={'pk': self.project.pk})
        data = {'description': 'Updated project'}
        response = self.client.put(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.project.refresh_from_db()
        self.assertEqual(self.project.description, 'Updated project')

    def test_update_project_unauthorized(self):
        self.client.force_authenticate(user=self.other_user)
        url = reverse('update-project', kwargs={'pk': self.project.pk})
        data = {'description': 'Hacked'}
        response = self.client.put(url, data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_delete_project(self):
        url = reverse('delete-project', kwargs={'pk': self.project.pk})
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(PROJECTS.objects.filter(pk=self.project.pk).exists())

    def test_delete_project_unauthorized(self):
        self.client.force_authenticate(user=self.other_user)
        url = reverse('delete-project', kwargs={'pk': self.project.pk})
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)