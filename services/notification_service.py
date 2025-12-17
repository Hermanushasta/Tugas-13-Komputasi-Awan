"""
Prinsip 4: Concurrency
Service untuk notifications - bisa di-scale independently
"""
from logger import get_logger

logger = get_logger(__name__)

class NotificationService:
    """Service untuk mengirim notifikasi"""
    
    def __init__(self):
        self.notifications = []
        logger.info("NotificationService initialized")
    
    def send_notification(self, message, recipient):
        """Send notification (simulasi)"""
        notification = {
            'message': message,
            'recipient': recipient,
            'sent': True
        }
        self.notifications.append(notification)
        
        logger.info(
            "Notification sent",
            recipient=recipient,
            notification_message=message
        )
        return notification
    
    def get_notifications(self):
        """Get all notifications"""
        logger.info("Retrieving notifications", count=len(self.notifications))
        return self.notifications
