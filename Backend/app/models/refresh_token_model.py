from datetime import datetime
from backend.app.db import db

class RefreshToken(db.Model):
    __tablename__ = "refresh_tokens"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id", ondelete="CASCADE"), nullable=False)
    jti = db.Column(db.String(64), nullable=False, unique=True)
    token_hash = db.Column(db.String(64), nullable=False, unique=True)  # sha256 hex
    revoked = db.Column(db.Boolean, default=False, nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    user = db.relationship("User", backref=db.backref("refresh_tokens", lazy=True))
