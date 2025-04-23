from django.urls import path
from . import views
from rest_framework_simplejwt.views import TokenRefreshView , TokenBlacklistView


urlpatterns = [
    # User registration and OTP verification
    path('register/', views.RegisterView.as_view(), name='register'),
    path('verify-email/', views.VerifyOTPView.as_view(), name='verify_email'),

    # Login 
    path('login/', views.MyTokenObtainPairView.as_view(), name='login'),

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
