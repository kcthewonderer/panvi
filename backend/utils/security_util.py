import hashlib
import uuid
from werkzeug.utils import secure_filename
from datetime import datetime

def generate_secure_filename(user_id, original_filename):
    # Sanitize the original filename
    clean_name = secure_filename(original_filename)
    
    # Generate a random component
    random_component = uuid.uuid4().hex[:8]
    
    # Add timestamp
    timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    
    # Create hash of user ID for additional security
    user_hash = hashlib.sha256(user_id.encode()).hexdigest()[:8]
    
    # Combine components
    extension = clean_name.rsplit('.', 1)[-1].lower() if '.' in clean_name else ''
    if extension:
        return f"{timestamp}_{user_hash}_{random_component}.{extension}"
    return f"{timestamp}_{user_hash}_{random_component}"