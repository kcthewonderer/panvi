import os
# services/storage_service.py
from google.cloud.exceptions import GoogleCloudError
from firebase_admin import storage, firestore
from werkzeug.utils import secure_filename
import datetime
import logging
from typing import Dict, Optional
import sys
from google.cloud import storage as gcs_storage
import imagesize
from io import BytesIO
import sys
from pathlib import Path


be_root = Path(__file__).resolve().parents[1]  # Adjust number based on depth
sys.path.append(str(be_root))

# Now import
from utils.security_util import generate_secure_filename
from utils.auth_util import get_authenticated_user
from config.firebase_configs import firestore_db


# Configure logging
logger = logging.getLogger(__name__)

class StorageException(Exception):
    """Custom exception for storage operations"""
    pass

class StorageService:
    def __init__(self):
        """Initialize with security defaults"""
        self.bucket = storage.bucket(os.environ['FIREBASE_STORAGE_BUCKET'])  
        self.max_file_size = 5 * 1024 * 1024  # 5MB
        self.allowed_types = ['jpeg', 'png', 'gif', 'webp']
        
    def _validate_image(self, file_stream: BytesIO) -> bool:
        """Validate image content type and size"""
        file_stream.seek(0)
        
        # Check file size
        if len(file_stream.read()) > self.max_file_size:
            raise StorageException(f"File exceeds maximum size of {self.max_file_size/1024/1024}MB")
        file_stream.seek(0)
        
        # Verify actual image type
        detected_type = imagesize(None, h=file_stream.read())
        file_stream.seek(0)
        
        if detected_type not in self.allowed_types:
            raise StorageException(f"Invalid image type. Allowed: {', '.join(self.allowed_types)}")
        return True
    
    def _generate_secure_path(self, user_id: str, original_name: str) -> str:
        """Create secure storage path with validation"""
        secure_name = generate_secure_filename(user_id, original_name)
        path = f"users/{user_id}/food-images/{secure_name}"
        
        # Prevent path traversal
        if not all(part not in ('..', '.') for part in path.split('/')):
            raise StorageException("Invalid file path")
            
        return path
    
    def upload_food_image(self, user_id: str, file_stream: BytesIO, content_type: str) -> Dict:
        """
        Securely upload food image with validation

        """
        try:
            # 1. Validate input
            if not user_id or not isinstance(user_id, str):
                raise StorageException("Invalid user ID")
                
            # 2. Validate image content
            self._validate_image(file_stream)
            
            # 3. Generate secure path
            blob_path = self._generate_secure_path(user_id, file_stream.filename)
            
            # 4. Upload with metadata
            blob = self.bucket.blob(blob_path)
            blob.metadata = {
                'uploaded_by': user_id,
                'original_filename': secure_filename(file_stream.filename),
                'content_type': content_type
            }
            
            blob.upload_from_string(
                file_stream.read(),
                content_type=content_type
            )
            
            # 5. Generate signed URL (more secure than public URL)
            signed_url = blob.generate_signed_url(
                expiration=datetime.timedelta(days=7),
                version='v4',
                method='GET'
            )
            
            logger.info(f"Successfully uploaded image for user {user_id}: {blob_path}")
            
            return {
                'file_name': blob_path.split('/')[-1],
                'signed_url': signed_url,
                'path': blob_path,
                'content_type': content_type
            }
            
        except GoogleCloudError as e:
            logger.error(f"Google Cloud error during upload: {str(e)}")
            raise StorageException("Failed to upload image to cloud storage")
        except Exception as e:
            logger.error(f"Unexpected upload error: {str(e)}")
            raise StorageException("Image upload failed")


def add_food_item(request, item_data: Dict, image_file: Optional[BytesIO] = None) -> Dict:
    """
    Add food item with authentication and secure image handling
    
    Args:
        request: Flask request object
        item_data: Dictionary of item attributes
        image_file: Optional file stream
        
    Returns:
        Dictionary containing item reference and upload details
    """
    try:
        # Get authenticated user
        user = get_authenticated_user(raise_exception=True)
        user_id = user['uid']
        
        storage_service = StorageService()
        image_info = None
        
        if image_file:
            image_info = storage_service.upload_food_image(
                user_id=user_id,
                file_stream=image_file,
                content_type=image_file.content_type
            )
            item_data['image_url'] = image_info['signed_url']
        
        item_data.update({
            'created_at': firestore.SERVER_TIMESTAMP,
            'updated_at': firestore.SERVER_TIMESTAMP,
            'owner_id': user_id  # Important for security rules
        })
        
        item_ref = firestore_db.collection('users').document(user_id)\
                            .collection('inventory').document()
        item_ref.set(item_data)
        
        logger.info(f"User {user_id} added food item {item_ref.id}")
        
        return {
            'item_id': item_ref.id,
            'image_info': image_info,
            'timestamp': datetime.datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to add food item: {str(e)}")
        raise