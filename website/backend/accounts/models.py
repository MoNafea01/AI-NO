from django.db import models
from django.contrib.auth.models import AbstractUser  # Django custom User
from django.utils.timezone import now
from django.db.models.signals import post_save
from django.dispatch import receiver
import random
import string
import uuid
# ========================
# User Model
# ========================
class User(AbstractUser):
    """
    Custom user model where email is used as the unique identifier.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=255 , unique=True)
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    USERNAME_FIELD = 'email'  # Use email for authentication
    REQUIRED_FIELDS = ['username', 'first_name', 'last_name']
    def __str__(self):
        return self.username


# ========================
# Profile Model
# ========================
class Profile(models.Model):
    """
    Profile model linked to the User model via a one-to-one relationship.
    Stores additional user details such as bio, image, and verification status.
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE)  # One-to-one link to User
    full_name = models.CharField(max_length=1000)  # Stores the user's full name
    bio = models.CharField(max_length=100, blank=True, null=True , default="")  # Short bio of the user
    image = models.ImageField(upload_to="user_images/", default="default.jpg")  # Profile picture
    verified = models.BooleanField(default=False)  # Indicates if the user is verified
    otp = models.CharField(max_length=6, blank=True, null=True)  # Stores OTP for verification
    is_otp_verified = models.BooleanField(default=False) # Indicates if the OTP is verified
    otp_created_at = models.DateTimeField(blank=True, null=True)  # Timestamp of OTP creation
    def generate_otp(self):
        """
        Generates a 6-digit OTP, saves it to the profile, and updates the timestamp.
        """
        self.otp = ''.join(random.choices(string.digits, k=6))  # Generate random 6-digit OTP
        self.otp_created_at = now()  # Set the OTP creation time
        self.save()  # Save the changes to the database

    def is_otp_valid(self, otp_code):
        """
        Validates if the given OTP is correct and not expired (valid for 5 minutes).
        If expired, it resets the OTP fields.
        """
        if self.otp and self.otp_created_at :
            time_diff = now() - self.otp_created_at
            if time_diff.total_seconds() > 300:  # OTP expires after 5 minutes
                self.otp = None
                self.otp_created_at = None
                self.save()
                return False  # OTP is expired
            return self.otp == otp_code  # Returns True if OTP matches
        return False




# ========================
# Signals
# ========================
@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    """
    Signal to create or update profile whenever user is saved.
    """
    if created:
        profile = Profile.objects.create(user=instance)
        profile.full_name = f"{instance.first_name} {instance.last_name}"
        if instance.is_superuser:
            profile.verified = True
        profile.save()
    else:
        instance.profile.full_name = f"{instance.first_name} {instance.last_name}"
        instance.profile.save()
        

    
    

class Topic(models.Model):
    host = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    title = models.CharField(max_length=250)
    description = models.TextField()
    participants = models.ManyToManyField(User,related_name='participants', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    
class Post(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    topic = models.ForeignKey(Topic, on_delete=models.CASCADE, related_name='posts')  #one topic can have many posts
    title = models.CharField(max_length=250)
    content = models.TextField()
    upvotes = models.ManyToManyField(User, related_name='upvoted_posts', blank=True, default=0)
    downvotes = models.ManyToManyField(User, related_name='downvoted_posts', blank=True, default=0) 
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    @property
    def upvotes_count(self):
        return self.upvotes.count()
    
    @property
    def downvotes_count(self):
        return self.downvotes.count()
    
    
    
class Comment(models.Model):
    body = models.TextField()
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null = True)
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Comment by {self.user.username} on {self.post.title}"
    