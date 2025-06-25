from django.shortcuts import get_object_or_404, render
from .models import User , Profile, Post, Topic, Comment
from .serializers import (
    UserSerializer ,
    MyTokenObtainPairSerializer ,
    ChangePasswordSerializerWithOtp ,
    RegisterSerializer ,
    ChangePasswordSerializer ,
    OTPVerificationSerializer,
    CreatePostSerializer,
    ListPostsSerializer,
    UpdatePostSerializer,
    CommunitySerializer,
    CommentSerializer,
    CreateCommentSerializer,
    )

from rest_framework.decorators import api_view , permission_classes
from rest_framework.response import Response
from rest_framework import generics
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework import status
from rest_framework.views import APIView
# for access and refresh token 
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.generics import RetrieveUpdateAPIView
from .utils import send_otp_email
# Create your views here.
from django.contrib.auth.hashers import check_password
###################################################################


########################################### for signup ######################################################
class RegisterView(generics.CreateAPIView):
    """
    API endpoint for user registration.
    After successful registration, an OTP is generated and sent to the user's email.
    """
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer
    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        user = User.objects.get(email=response.data['email'])
        user.profile.generate_otp()
        if user.profile.otp :
            user.profile.save()
            send_otp_email(user)
        token = MyTokenObtainPairSerializer.get_token(user)
        return Response(
                {
                    "message": "OTP has been sent to your email. Please verify your account.",
                    "access": str(token.access_token),
                    "refresh": str(token)
                },
                status=status.HTTP_201_CREATED
            )


################################### verify user after signup using OTP ############################################
class VerifyOTPView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    """
    API endpoint for verifying OTP to activate a user account.
    """
    def post(self, request):
        serializer = OTPVerificationSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        email = request.user.email
        otp = serializer.validated_data["otp"]
        if not otp :
            return Response({"error": "OTP is required"}, status=status.HTTP_400_BAD_REQUEST)
        user = get_object_or_404(User, email=email)
        profile = user.profile
        if profile.is_otp_valid(otp) :
            profile.verified = True
            profile.otp = None  # Remove OTP after successful verification
            profile.otp_created_at = None
            profile.save()
            token = MyTokenObtainPairSerializer.get_token(user)
            return Response(
                {
                    "message": "Account verified successfully",
                    "access": str(token.access_token),
                    "refresh": str(token)
                },
                status=status.HTTP_200_OK
            )
        # Call RequestOTPView to get new otp  via this url request-otp/
        return Response({"error": "Invalid or expired OTP, Ask for new one"}, status=status.HTTP_400_BAD_REQUEST)

######################################################################################

########################################### For Login ###########################################
class MyTokenObtainPairView(TokenObtainPairView):
    """
    Standard login with username & password.
    """
    serializer_class = MyTokenObtainPairSerializer

######################################################################################

##################################### User profile Get and Update #################################################
class UserProfileView(RetrieveUpdateAPIView):
    """
    API endpoint to retrieve and update user profile.
    """
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        """
        Override update to allow partial updates and ensure profile updates.
        """
        user = self.get_object()
        serializer = self.get_serializer(user, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
################################################################################################################


############################## change password with old one ###############################################
class ChangePasswordView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.update_password(request.user)
            token = MyTokenObtainPairSerializer.get_token(request.user)
            return Response(
                {
                    "message": "password updated",
                    "access": str(token.access_token),
                    "refresh": str(token)
                },
                status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#############################################################################################################

#################################### change password with OTP #####################################################
# ask for otp to change password
class RequestOTPView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    def post(self, request):
        email = request.user.email
        try:
            user = User.objects.get(email=email)
            profile = user.profile
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        profile.generate_otp()
        profile.save()
        if send_otp_email(user):
            return Response({"message": "OTP sent successfully"}, status=status.HTTP_200_OK)
        else:
            return Response({"error": "Failed to send OTP email"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)




                            ######################################

# check otp then change password
class VerifyOTPForPasswordChangeView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    def post(self, request):
        serializer = OTPVerificationSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        email = request.user.email
        otp = serializer.validated_data["otp"]
        try:
            user = User.objects.get(email=email)
            profile = user.profile
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        if not profile.is_otp_valid(otp):
            # Call RequestOTPView to get new otp  via this url request-otp/
            return Response({"error": "Invalid or expired OTP"}, status=status.HTTP_400_BAD_REQUEST)
        profile.is_otp_verified = True
        profile.otp_created_at = None
        profile.otp = None
        profile.save()
        return Response({"message": "OTP verified successfully. You can now reset your password."}, status=status.HTTP_200_OK)


# Reset password
class ChangePasswordWithOTPView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    def post(self, request):
        email = request.user.email
        try:
            user = User.objects.get(email=email)
            profile = user.profile
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        if not profile.is_otp_verified:
            return Response({"error": "OTP verification required before changing password."}, status=status.HTTP_400_BAD_REQUEST)
        change_password_serializer = ChangePasswordSerializerWithOtp(data=request.data, context={'user': user})
        if change_password_serializer.is_valid():
            change_password_serializer.update_password(user)
            token = MyTokenObtainPairSerializer.get_token(user)
            profile.is_otp_verified = False
            profile.save()
            return Response(
                {
                    "message": "Password changed successfully.",
                    "access": str(token.access_token),
                    "refresh": str(token)
                },
                status=status.HTTP_200_OK
            )
        return Response(change_password_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

###################################################################################################################

class PostVoteAPIView(APIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request, pk, vote_type):
        try:
            post = Post.objects.get(pk=pk)
        except Post.DoesNotExist:
            return Response({"error": "Post Not Found"}, status=status.HTTP_404_NOT_FOUND)
    
        user = request.user
        
        if vote_type == 'upvote':
            if post.upvotes.filter(id=user.id).exists():
                post.upvotes.remove(user)
                message = "Upvote Removed"
            else:
                if post.downvotes.filter(id=user.id).exists():
                    post.downvotes.remove(user)
                post.upvotes.add(user)
                message = "Upvoted Successfully"
        
        elif vote_type == 'downvote':
            if post.downvotes.filter(id=user.id).exists():
                post.downvotes.remove(user)
                message = "Downvote Removed"
            else:
                if post.upvotes.filter(id=user.id).exists():
                    post.upvotes.remove(user)
                post.downvotes.add(user)
                message = "Downvoted Successfully"
        else:
            return Response({"error":"Invalid Vote Type"}, status=status.HTTP_400_BAD_REQUEST) 
        
        serializer = ListPostsSerializer(post, context={"request": request})
        return Response({"message": message, "post": serializer.data}, status=status.HTTP_200_OK)       
            
    
class CreateListPostsAPIView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticatedOrReadOnly] # anyone can read, only authenticated users can post
    queryset = Post.objects.all().order_by('-created_at')
    
    def get_serializer_class(self):
        if self.request.method == "POST":
            return CreatePostSerializer
        return ListPostsSerializer
    
    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def perform_create(self, serializer):
        serializer.save(user = self.request.user) #auto-set the current user
        
    
class UpdateDeletePostAPIView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Post.objects.all()
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return UpdatePostSerializer
        return ListPostsSerializer
    
    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def get_queryset(self):
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return self.queryset.filter(user=self.request.user)
        return self.queryset
        

class ListCreateTopicAPIView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticatedOrReadOnly]
    queryset = Topic.objects.all().order_by('-created_at')
    serializer_class = CommunitySerializer
    
    def perform_create(self, serializer):
        serializer.save(host = self.request.user)
        
    
class RetrieveUpdateDestroyTopicAPIView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticatedOrReadOnly]
    queryset = Topic.objects.all()
    serializer_class = CommunitySerializer
    
    def get_queryset(self):
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return self.queryset.filter(host=self.request.user)
        return self.queryset 
    
    
class CommentListCreateAPIView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get_queryset(self):
        post_id = self.kwargs['post_id']
        return Comment.objects.filter(post_id=post_id).order_by('-created_at')
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return CreateCommentSerializer
        return CommentSerializer
    
    def perform_create(self, serializer):
        post = get_object_or_404(Post, pk=self.kwargs['post_id'])
        serializer.save(user = self.request.user, post=post)




class CommentRetrieveUpdateDestroyAPIView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticatedOrReadOnly]
    serializer_class = CommentSerializer
    
    def get_queryset(self):
        return Comment.objects.filter(post = self.kwargs['post_id'])
    
    def get_object(self):
        queryset = self.get_queryset()
        obj = get_object_or_404(queryset, pk=self.kwargs['comment_id'])
        self.check_object_permissions(self.request, obj)
        return obj






@api_view(['GET'])
def getRoutes(request):
    routes = [
    "/register/",
    "/verify-email/",
    "/login/",
    "/change-password/",
    "/request-otp/",
    "/verify-otp-for-password/",
    "/reset-password/",
    "/profile/",
    "/token/refresh/",
    "/token/blacklist/",
    ]
    return Response(routes)
