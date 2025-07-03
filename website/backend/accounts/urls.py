from django.urls import path
from . import views
from rest_framework_simplejwt.views import TokenRefreshView , TokenBlacklistView


urlpatterns = [
    # User registration and OTP verification
    path('register/', views.RegisterView.as_view(), name='register'),
    path('verify-email/', views.VerifyOTPView.as_view(), name='verify_email'),

    # Login 
    path('login/', views.MyTokenObtainPairView.as_view(), name='login'),
    
    # posts
    path('posts/', views.CreateListPostsAPIView.as_view(), name='post-create-list'),
    path('posts/<int:pk>/', views.UpdateDeletePostAPIView.as_view(), name='post-update-retrieve-delete'),
    path('posts/<int:pk>/upvote/', views.PostVoteAPIView.as_view(), {'vote_type':'upvote'}, name='post-upvote'),
    path('posts/<int:pk>/downvote/', views.PostVoteAPIView.as_view(), {'vote_type':'downvote'}, name='post-downvote'),
    path('posts/<int:post_id>/comments/', views.CommentListCreateAPIView.as_view(), name ='comment-list-create'),
    path('posts/<int:post_id>/comments/<int:comment_id>/', views.CommentRetrieveUpdateDestroyAPIView.as_view(), name='comment-retrieve-update-delete'),
    # community
    path('topics/', views.ListCreateTopicAPIView.as_view(), name = 'topic-list-create'),
    path('topics/<pk>/', views.RetrieveUpdateDestroyTopicAPIView.as_view(), name='topic-retrieve-update-delete'),

    # change_password_with_old_password
    path('change-password/', views.ChangePasswordView.as_view(), name='change-password-with-old-password'),

    # change_password_with-otp  or Verify email
    path('request-otp/', views.RequestOTPView.as_view(), name='request_password_reset_otp'),

    path('verify-otp-for-password/', views.VerifyOTPForPasswordChangeView.as_view(), name='verify_otp'),
    path('reset-password/', views.ChangePasswordWithOTPView.as_view(), name='reset_password_with_otp'),


    # User profile
    path('profile/', views.UserProfileView.as_view(), name='profile'),


    # Token management
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # logout (takes refresh token)
    path('token/blacklist/', TokenBlacklistView.as_view(), name='token_blacklist'),

    # Miscellaneous
    path('', views.getRoutes),
]
