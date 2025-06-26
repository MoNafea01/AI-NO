# for testing => python manage.py test accounts

from django.test import TestCase
from django.utils import timezone
from .models import User, Profile, Topic, Post, Comment
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework.test import APIRequestFactory
from rest_framework.parsers import MultiPartParser

class ModelsTestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="ahmedemad",
            email="ahmed@example.com",
            first_name="Ahmed",
            last_name="Emad",
            password="strongpass123"
        )

    def test_profile_created(self):
        self.assertTrue(hasattr(self.user, 'profile'))
        self.assertEqual(self.user.profile.full_name, "Ahmed Emad")

    def test_generate_otp(self):
        self.user.profile.generate_otp()
        self.assertIsNotNone(self.user.profile.otp)
        self.assertIsNotNone(self.user.profile.otp_created_at)

    def test_valid_otp(self):
        self.user.profile.generate_otp()
        otp = self.user.profile.otp
        self.assertTrue(self.user.profile.is_otp_valid(otp))

    def test_topic_post_comment(self):
        topic = Topic.objects.create(host=self.user, title="Test Topic", description="Description")
        post = Post.objects.create(user=self.user, topic=topic, title="Test Post", content="Some content")
        comment = Comment.objects.create(user=self.user, post=post, body="Nice post!")

        self.assertEqual(topic.posts.count(), 1)
        self.assertEqual(post.comments.count(), 1)
        self.assertEqual(str(comment), f"Comment by {self.user.username} on {post.title}")

    def test_vote_counts(self):
        topic = Topic.objects.create(host=self.user, title="T1", description="D1")
        post = Post.objects.create(user=self.user, topic=topic, title="T", content="C")
        post.upvotes.add(self.user)
        self.assertEqual(post.upvotes_count, 1)
        self.assertEqual(post.downvotes_count, 0)


# accounts/tests/test_serializers.py
from django.test import TestCase
from accounts.models import User, Profile, Post, Topic, Comment
from accounts.serializers import *
from rest_framework.exceptions import ValidationError

class SerializerTestCase(TestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create_user(
            username="ahmed",
            email="ahmed@test.com",
            password="StrongPass123",
            first_name="Ahmed",
            last_name="Emad"
        )
        self.user.profile.verified = True
        self.user.profile.save()

    def test_register_serializer(self):
        data = {
            'username': 'newuser',
            'email': 'new@test.com',
            'first_name': 'New',
            'last_name': 'User',
            'password': 'StrongPass123',
            'password2': 'StrongPass123'
        }
        serializer = RegisterSerializer(data=data)
        self.assertTrue(serializer.is_valid())

    def test_user_serializer_update(self):
        # Enter valid image path !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        with open(r"C:\Users\anaah\OneDrive\Pictures\Screenshots 1\Screenshot 2024-11-23 200745.png", "rb") as img_file:
            image = SimpleUploadedFile(
                name="test_image.png",
                content=img_file.read(),
                content_type="image/png"
            )
        request = self.factory.put(
        '/',
        data={},
        format='multipart'
        )
        update_data = {
        'username': 'updateduser',
        'first_name': 'Updated',
        'last_name': 'User',
        'email': 'updated@example.com',
        'profile': {
            'full_name': 'Updated User',
            'bio': 'Updated bio',
            'image':image,
            }
        }

        serializer = UserSerializer(instance=self.user, data=update_data, context={'request': request} )
    
        if not serializer.is_valid():
            print("Serializer errors:", serializer.errors)
        
        self.assertTrue(serializer.is_valid())
        serializer.save()
        self.user.refresh_from_db()
        self.assertEqual(self.user.username, 'updateduser')
        self.assertEqual(self.user.profile.bio, 'Updated bio')

    def test_change_password_serializer(self):
        data = {
            'old_password': 'StrongPass123',
            'new_password': 'NewStrongPass123',
            'confirm_password': 'NewStrongPass123'
        }
        request = type('Request', (), {'user': self.user})
        serializer = ChangePasswordSerializer(data=data, context={'request': request})
        self.assertTrue(serializer.is_valid())


# accounts/tests/test_views.py
from rest_framework.test import APITestCase
from django.urls import reverse
from accounts.models import User, Post, Topic, Comment
from rest_framework import status

class ViewsTestCase(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="ahmed",
            email="ahmed@example.com",
            password="StrongPass123",
            first_name="Ahmed",
            last_name="Emad"
        )
        self.user.profile.verified = True
        self.user.profile.save()
        self.register_url = reverse('register')
        self.login_url = reverse('login')
        self.profile_url = reverse('profile')
        self.posts_url = reverse('post-create-list')
        self.topics_url = reverse('topic-list-create')
        self.otp_url = reverse('request_password_reset_otp')

    def authenticate(self):
        res = self.client.post(self.login_url, {'email': 'ahmed@example.com', 'password': 'StrongPass123'}, format='json')
        token = res.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    def test_user_registration(self):
        data = {
            'username': 'testuser',
            'email': 'test@test.com',
            'first_name': 'Test',
            'last_name': 'User',
            'password': 'StrongPass123',
            'password2': 'StrongPass123'
        }
        res = self.client.post(self.register_url, data, format='json')
        self.assertEqual(res.status_code, 201)

    def test_login(self):
        res = self.client.post(self.login_url, {'email': 'ahmed@example.com', 'password': 'StrongPass123'})
        self.assertEqual(res.status_code, 200)
        self.assertIn('access', res.data)

    def test_profile_retrieve(self):
        self.authenticate()
        res = self.client.get(self.profile_url)
        self.assertEqual(res.status_code, 200)

    def test_create_post(self):
        self.authenticate()
        topic = Topic.objects.create(host=self.user, title='Topic1', description='desc')
        data = {'title': 'Test Post', 'content': 'Content here', 'topic': topic.id}
        res = self.client.post(self.posts_url, data)
        self.assertEqual(res.status_code, 201)

    def test_create_comment(self):
        self.authenticate()
        topic = Topic.objects.create(host=self.user, title='Topic1', description='desc')
        post = Post.objects.create(user=self.user, topic=topic, title='Post1', content='content')
        url = reverse('comment-list-create', kwargs={'post_id': post.id})
        data = {'body': 'Nice'}
        res = self.client.post(url, data)
        self.assertEqual(res.status_code, 201)

    def test_create_topic(self):
        self.authenticate()
        data = {'title': 'Test Community', 'description': 'Discuss AI'}
        res = self.client.post(self.topics_url, data)
        self.assertEqual(res.status_code, 201)

    def test_vote_post(self):
        self.authenticate()
        topic = Topic.objects.create(host=self.user, title='Topic1', description='desc')
        post = Post.objects.create(user=self.user, topic=topic, title='Post', content='C')
        url = reverse('post-upvote', kwargs={'pk': post.id})
        res = self.client.post(url)
        self.assertEqual(res.status_code, 200)
        self.assertIn('Upvoted Successfully', res.data['message'])
