import logging
from django.core.mail import send_mail


logger = logging.getLogger(__name__)

def send_otp_email(user):
    """
    Sends an OTP email to the user for verification.
    """
    if not user.profile.otp:
        return False  # No OTP available

    subject = "OTP Code for Verification"
    message = f"Hello {user.first_name},\n\nYour OTP code is: {user.profile.otp}\n\nThis code is valid for 5 minutes."
    from_email = "anaahmed1512@gmail.com"
    recipient_list = [user.email]

    try:
        sent_count = send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        return sent_count > 0  # Returns True if email was sent successfully
    except Exception as e:
        logger.error(f"Error sending OTP email: {e}")  # Log error (Replace with proper logging in production)
        return False