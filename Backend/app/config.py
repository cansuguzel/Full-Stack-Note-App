import os
from dotenv import load_dotenv

load_dotenv()  # uploads environment variables from .env file

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY")
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # OAuth
    CLIENT_ID = os.getenv("CLIENT_ID")
    CLIENT_SECRET = os.getenv("CLIENT_SECRET")
    REDIRECT_URI = os.getenv("REDIRECT_URI")

    ACCESS_TOKEN_EXPIRES_MIN = int(os.getenv("ACCESS_TOKEN_EXPIRES_MIN"))  
    REFRESH_TOKEN_EXPIRES_MIN = int(os.getenv("REFRESH_TOKEN_EXPIRES_MIN"))  