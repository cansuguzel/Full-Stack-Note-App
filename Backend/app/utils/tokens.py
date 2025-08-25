from datetime import datetime, timedelta
import hashlib
import os
import uuid
import jwt
from backend.app import db
from backend.app.config import Config 
from google.oauth2 import id_token
from google.auth.transport import requests

from backend.app.models.refresh_token_model import RefreshToken 

# Utility function to generate an access token
def generate_access_token(user_id):
    payload = {
        "user_id": user_id,
        "exp": datetime.utcnow() + timedelta(minutes=Config.ACCESS_TOKEN_EXPIRES_MIN),
        "iat": datetime.utcnow()
    }
    return jwt.encode(payload, Config.SECRET_KEY, algorithm="HS256")

# Utility function to decode a token
def decode_token(token):
    try:
        payload = jwt.decode(token, Config.SECRET_KEY, algorithms=["HS256"])
        return payload, None
    except jwt.ExpiredSignatureError:
        return None, "Your session has expired. Please log in again."
    except jwt.InvalidTokenError:
        return None, "Invalid authentication token. Please log in again."




# Utility function to generate a refresh token
def generate_refresh_token(user_id):
    raw_token = str(uuid.uuid4()) + str(uuid.uuid4())  # the token it will give user
    token_hash = hashlib.sha256(raw_token.encode()).hexdigest()  # the hash to store in DB
    jti = str(uuid.uuid4())  # the unique identifier for the token

    db_token = RefreshToken(
        user_id=user_id,
        jti=jti,
        token_hash=token_hash,
        expires_at=datetime.utcnow() + timedelta(minutes=Config.REFRESH_TOKEN_EXPIRES_MIN),
        revoked=False
    )

    db.session.add(db_token)
    db.session.commit()

    return raw_token  # the token it will give user

# Utility function to verify a refresh token
def verify_refresh_token(raw_token):
    token_hash = hashlib.sha256(raw_token.encode()).hexdigest()

    db_token = RefreshToken.query.filter_by(token_hash=token_hash).first()

    if not db_token:
        return None, "Invalid refresh token"
    if db_token.revoked:
        #  reuse detection triggered in here
        RefreshToken.query.filter_by(user_id=db_token.user_id).update({"revoked": True})
        db.session.commit()
        return None, "Detected token reuse! All sessions revoked."

    if db_token.expires_at < datetime.utcnow():
        return None, "Refresh token expired"

    return db_token, None


# Refresh Token Rotation
def rotate_refresh_token(old_db_token):
    old_db_token.revoked = True  # Revoke the old token
    new_raw_token = str(uuid.uuid4()) + str(uuid.uuid4())
    new_token_hash = hashlib.sha256(new_raw_token.encode()).hexdigest()
    new_jti = str(uuid.uuid4())

    new_token = RefreshToken(
        user_id=old_db_token.user_id,
        jti=new_jti,
        token_hash=new_token_hash,
        expires_at=datetime.utcnow() + timedelta(minutes=Config.REFRESH_TOKEN_EXPIRES_MIN),
        revoked=False
    )

    db.session.add(new_token)
    db.session.commit()

    return new_raw_token

   

# Utility function to verify Google ID token and extract user info
def verify_google_id_token(token):
    try:
        idinfo = id_token.verify_oauth2_token(
            token,
            requests.Request(),
            os.getenv("CLIENT_ID")
        )
        return idinfo, None
    except ValueError as e:
        return None, "Google ID token is invalid."
    except Exception as e:
        return None, "An unexpected error occurred during token verification."