# utils/auth_utils.py
from firebase_admin import auth
from flask import request, jsonify
from functools import wraps
import logging

logger = logging.getLogger(__name__)

def get_authenticated_user(raise_exception=False):
    """
    Get authenticated user from Firebase token
    Args:
        raise_exception: Whether to raise exception or return None on failure
    Returns:
        Decoded token payload if valid, None otherwise
    """
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        if raise_exception:
            raise ValueError("Authorization header missing")
        return None

    try:
        # Expecting "Bearer <token>"
        token = auth_header.split(' ')[1]
        decoded_token = auth.verify_id_token(token)
        logger.info(f"Authenticated user: {decoded_token['uid']}")
        return decoded_token
    except IndexError:
        error = "Invalid Authorization header format. Expected 'Bearer <token>'"
    except ValueError as e:
        error = f"Invalid token: {str(e)}"
    except auth.InvalidIdTokenError:
        error = "Invalid Firebase ID token"
    except auth.ExpiredIdTokenError:
        error = "Expired Firebase ID token"
    except auth.RevokedIdTokenError:
        error = "Revoked Firebase ID token"
    except Exception as e:
        error = f"Authentication error: {str(e)}"

    logger.warning(f"Authentication failed: {error}")
    if raise_exception:
        raise PermissionError(error)
    return None

def auth_required(f):
    """
    Decorator to require Firebase authentication
    """
    @wraps(f)
    def wrapper(*args, **kwargs):
        user = get_authenticated_user(raise_exception=True)
        request.user = user  # Attach user to request object
        return f(*args, **kwargs)
    return wrapper