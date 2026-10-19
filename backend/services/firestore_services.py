from firebase_admin import firestore
import sys
from pathlib import Path

be_root = Path(__file__).resolve().parents[1]  # Adjust number based on depth
sys.path.append(str(be_root))

from config.firebase_configs import firestore_db


def create_user_document(user_id, email):
    user_ref = firestore_db.collection('users').document(user_id)
    
    user_data = {
        'email': email,
        'created_at': firestore.SERVER_TIMESTAMP,
        'last_login': firestore.SERVER_TIMESTAMP,
        'preferences': {
            'notifications': True,
            'language': 'English',
            'theme': 'Light',
            'measurment units': [],
            'food allergies': [],
            'dietary_restrictions': [],
            'favorite_cuisines': []
        },
        'inventory_settings': {
            'expiration_notification_days': 3,
            'low_quantity_threshold': 2
        }
    }
    
    user_ref.set(user_data)
    return user_ref