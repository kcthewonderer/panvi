# config/firebase_config.py
import os
import firebase_admin
from firebase_admin import credentials, firestore, storage
from pathlib import Path
from typing import Tuple
import logging
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FirebaseConfigError(Exception):
    """Custom exception class for Firebase configuration errors"""
    def __init__(self, message: str, original_exception: Exception = None):
        super().__init__(message)
        self.original_exception = original_exception
        self.message = message
        logger.error(f"FirebaseConfigError: {message}", exc_info=original_exception)

    def __str__(self):
        if self.original_exception:
            return f"{self.message} (Original: {type(self.original_exception).__name__}: {str(self.original_exception)})"
        return self.message

def initialize_firebase() -> Tuple[firebase_admin.App, firestore.client, storage.bucket]:
    
    try:
        # --------------------------------------------------
        # STEP 1: Locate and load environment configuration
        # --------------------------------------------------
        project_root = Path(__file__).resolve().parent.parent  # backend/
        env_path = project_root / '.env'
        
        if not env_path.exists():
            logger.warning(f"No .env file found at {env_path}. Using defaults.")
        else:
            load_dotenv(env_path)
        
        # --------------------------------------------------
        # STEP 2: Set configuration values
        # --------------------------------------------------
        config = {
            'credentials_file': os.getenv('FIREBASE_CREDENTIALS_FILE', 'firebase-adminsdk.json'),
            'storage_bucket': os.environ['FIREBASE_STORAGE_BUCKET'],
            'project_id': os.environ['FIREBASE_PROJECT_ID'],
            'database_url': os.getenv('FIREBASE_DATABASE_URL', '')
        }
        
        logger.info("Using Firebase configuration:")
        logger.info(f"  Credentials: {config['credentials_file']}")
        logger.info(f"  Storage Bucket: {config['storage_bucket']}")
        logger.info(f"  Project ID: {config['project_id']}")

        # --------------------------------------------------
        # STEP 3: Locate and verify service account file
        # --------------------------------------------------
        secrets_dir = project_root / 'secrets'
        creds_path = secrets_dir / config['credentials_file']
        
        if not secrets_dir.exists():
            raise FirebaseConfigError(
                f"Secrets directory not found at: {secrets_dir}\n"
                f"Please create this directory and add your service account JSON file."
            )
            
        if not creds_path.exists():
            available_files = "\n".join(f" - {f.name}" for f in secrets_dir.glob('*'))
            raise FirebaseConfigError(
                f"Service account file '{config['credentials_file']}' not found in {secrets_dir}\n"
                f"Available files:\n{available_files}\n"
                f"Please download your service account JSON from Firebase Console and place it here."
            )

        # --------------------------------------------------
        # STEP 4: Initialize Firebase Admin SDK
        # --------------------------------------------------
        try:
            cred = credentials.Certificate(str(creds_path))
        except ValueError as e:
            raise FirebaseConfigError(
                f"Invalid service account file at {creds_path}\n"
                f"Please verify the file is a valid Firebase service account JSON.",
                e
            )
        
        # --------------------------------------------------
        # STEP 5: Create Firebase app instance
        # --------------------------------------------------
        try:
            firebase_app = firebase_admin.initialize_app(
                cred,
                {
                    'storageBucket': config['storage_bucket'],
                    'projectId': config['project_id'],
                    'databaseURL': config['database_url']
                },
                name='food-inventory'
            )
        except Exception as e:
            raise FirebaseConfigError(
                f"Failed to initialize Firebase app. Please verify:\n"
                f"1. Your project ID matches the service account\n"
                f"2. Your storage bucket name is correct",
                e
            )

        # --------------------------------------------------
        # STEP 6: Initialize Firebase services
        # --------------------------------------------------
        firestore_db = firestore.client(app=firebase_app)
        storage_bucket = storage.bucket(app=firebase_app)

        logger.info("✅ Firebase services initialized successfully")
        return firebase_app, firestore_db, storage_bucket

    except Exception as e:
        raise FirebaseConfigError(
            "🔥 Critical Firebase initialization failure\n"
            "Please complete these setup steps:\n"
            "1. Copy backend/.env.example to backend/.env and fill it in\n"
            "2. Download service account JSON from Firebase Console\n"
            "3. Place it in backend/secrets/ (git-ignored)\n"
            f"Error details: {str(e)}",
            e
        ) from e

# Initialize Firebase when module is imported
try:
    firebase_app, firestore_db, storage_bucket = initialize_firebase()
except FirebaseConfigError as e:
    logger.critical(str(e))
    raise



