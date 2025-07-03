from rest_framework import serializers
from .models import User , Profile, Post, Topic, Comment

from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.hashers import check_password
# To edit jwt token
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from rest_framework.validators import UniqueValidator
from .utils import send_otp_email
####################

class OTPVerificationSerializer(serializers.Serializer):
    otp = serializers.CharField(max_length=6)


class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        # These are claims, you can add custom claims (data)
        if hasattr(user, 'profile'):  # Ensure profile exists
            token['full_name'] = user.profile.full_name
            token['bio'] = user.profile.bio
            token['image'] = str(user.profile.image)
            token['verified'] = user.profile.verified
        token['username'] = user.username
        token['email'] = user.email
        return token



class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = ['full_name', 'bio', 'image' , 'verified']


class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()
    class Meta :
        model = User
        fields = ('id', 'username', 'first_name' , 'last_name' , 'email' , 'profile')
        read_only_fields = ['id']
    def update(self, instance, validated_data):
        ''' method to update user an profile '''
        profile_data = validated_data.pop('profile', {})
        profile = instance.profile
        # update user data
        instance.username = validated_data.get('username', instance.username)
        instance.first_name = validated_data.get('first_name', instance.first_name)
        instance.last_name = validated_data.get('last_name', instance.last_name)
        instance.email = validated_data.get('email', instance.email)
        instance.save()
        # update profile data
        profile.full_name = profile_data.get('full_name', profile.full_name)
        profile.bio = profile_data.get('bio', profile.bio)
        profile.image = profile_data.get('image', profile.image)
        profile.save()
        return instance

# change password with old one
class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    new_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    def validate(self, data):
        """ check the data """
        user = self.context['request'].user
        # if account not active
        if not user.is_active:
            raise serializers.ValidationError({"user": "This account is deactivated."})
        # check old password
        elif not check_password(data['old_password'], user.password):
            raise serializers.ValidationError({"old_password": "wrong password"})
        # to make sure the user write new password
        elif data['new_password'] == data['old_password']:
            raise serializers.ValidationError({"confirm_password": "new password is same old password "})
        # check password1 and password2
        elif data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({"confirm_password": "Passwords do not match."})
        return data
    def update_password(self, user):
        """ update password for the current user """
        user = self.context['request'].user
        user.set_password(self.validated_data['new_password'])
        user.save()


# change password without old one but with otp
class ChangePasswordSerializerWithOtp(serializers.Serializer):
    new_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    def validate(self, data):
        user = self.context.get('user')
        if not user:
            raise serializers.ValidationError({"user": "User not found."})
        try:
            profile = Profile.objects.get(user=user)
        except Profile.DoesNotExist:
            raise serializers.ValidationError({"profile": "Profile not found."})
        if check_password(data['new_password'], user.password):
            raise serializers.ValidationError({"new_password": "New password cannot be the same as the old password."})
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({"confirm_password": "Passwords do not match."})
        return data
    def update_password(self, user):
        user.set_password(self.validated_data['new_password'])
        user.save()
        profile = Profile.objects.get(user=user)
        profile.otp = None
        profile.save()


class RegisterSerializer(serializers.ModelSerializer):
    '''Serializer for user registration.
    This serializer is responsible for handling user registration by
    validating passwords, ensuring password confirmation, and creating
    a new user with a hashed password.
    '''
    # Define password field, making it write-only and required, with password validation
    password = serializers.CharField(write_only=True, required=True ,validators=[validate_password])
    # Define password2 (confirmation password) with the same constraints as password
    password2 = serializers.CharField(write_only=True, required=True , validators=[validate_password])
    class Meta:
        '''
        Meta class specifying the model and fields to be included in the serializer.
        '''
        model = User
        # Fields to be handled
        fields = ('email', 'username', 'first_name' , 'last_name' , 'password', 'password2')
    def validate(self, attrs):
        '''
        Validate that password and password2 match.
        Raises:
            serializers.ValidationError: If the two password fields do not match.
        '''
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError( {"password": "Password fields didn't match."} )
        # Return validated data if passwords match
        return attrs
    def create(self, validated_data):
        '''
        Create and return a new user instance after hashing the password.
        Args:
            validated_data (dict): The validated user data.
        Returns:
            User: The created user instance.
        '''
        # Create user instance without setting the password directly ( save the data )
        user = User.objects.create(username=validated_data['username'],first_name=validated_data['first_name'],last_name=validated_data['last_name'],email=validated_data['email'])
        # Hash the password before saving the user
        user.set_password(validated_data['password'])
        # Save the user to the database
        user.save()
        # Then return the created user instance
        return user
    
    
class CreatePostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ['title','content', 'topic']
        
        
class ListPostsSerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField() # shows username instead of ID
    upvotes = serializers.SerializerMethodField()
    downvotes = serializers.SerializerMethodField()
    has_upvoted = serializers.SerializerMethodField()
    has_downvoted = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    comment_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Post
        fields = ['id', 'user', 'title', 'content', 'topic', 'upvotes', 'downvotes', 'comment_count',
                  'has_upvoted', 'has_downvoted', 'created_at', 'updated_at','comments'] 
    
    def get_upvotes(self, obj):
        return obj.upvotes.count()
    
    def get_downvotes(self, obj):
        return obj.downvotes.count()
    
    def get_has_upvoted(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.upvotes.filter(id=request.user.id).exists()
        return False
    
    def get_has_downvoted(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.downvotes.filter(id=request.user.id).exists()
        return False 
    
    def get_comments(self, obj):
        comments = obj.comments.all()[:3] #get the first 3 comments
        return CommentSerializer(comments, many=True).data
    
    def get_comment_count(self,obj):
        return obj.comments.count()   
    
    
        
class UpdatePostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ['title', 'content']
        read_only_fields = ['user']
        
    
class CommunitySerializer(serializers.ModelSerializer):
    host = serializers.StringRelatedField()
    participants = serializers.StringRelatedField()
    class Meta:
        model = Topic
        fields = ['id', 'host','title', 'description', 'participants','created_at', 'updated_at']
        read_only_fields = ['id', 'host', 'participants', 'created_at', 'updated_at']
        

class CommentSerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField()
    user_image = serializers.SerializerMethodField()
    class Meta:
        model = Comment
        fields = ['id', 'user', 'body', 'user_image', 'created_at', 'updated_at'] #add user image
        read_only_fields = ['user', 'created_at', 'updated_at']
        
    def get_user_image(self,obj):
        if obj.user.profile.image:
            return obj.user.profile.image.url
        return None
    

class CreateCommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ['body']
        