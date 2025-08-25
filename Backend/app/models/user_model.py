from backend.app.db import db
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model):
    
    id = db.Column(db.Integer, primary_key=True)  # Internal PK

    email = db.Column(db.String(150), unique=True, nullable=False)
    name = db.Column(db.String(100))

    hashed_password = db.Column(db.String(200), nullable=True)     # only for email login
    google_id = db.Column(db.String(100), unique=True, nullable=True)  # only for Google users

    provider = db.Column(db.String(20), default='email')  # 'email' or 'google'

    notes = db.relationship('Note', backref='user', cascade='all, delete-orphan')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

       # storing password securely
    def set_password(self, password):
        self.hashed_password = generate_password_hash(password) #password hashing

    # controlling password
    def check_password(self, password):
        return check_password_hash(self.hashed_password, password)
