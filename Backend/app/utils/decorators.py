from functools import wraps
from flask import request, jsonify
from backend.app.models.note_model import Note
from backend.app.utils.tokens import decode_token
from backend.app.models.user_model import User

def token_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')

        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"message": "Authorization header missing or invalid."}), 401

        token = auth_header.split(" ")[1]
        payload, error = decode_token(token)

        if error:
            return jsonify({"message": error}), 401

        user = User.query.get(payload.get("user_id"))
        if not user:
            return jsonify({"message": "User not found."}), 404

        return f(user=user, *args, **kwargs)

    return decorated_function

def self_access_required(f):
    @wraps(f)
    def decorated_function(user, user_id, *args, **kwargs):
        if user.id != user_id:
            return {"message": "You can only access your own account."}, 403
        return f(user, user_id, *args, **kwargs)
    return decorated_function

def owner_required(f):
    @wraps(f)
    def decorated_function(user, note_id, *args, **kwargs):
        note = Note.query.get(note_id)

        if not note:
            return jsonify({"message": "Note not found."}), 404

        if note.user_id != user.id:
            return jsonify({"message": "Note does not belong to you."}), 403

        request.note = note
        return f(user, note_id, *args, **kwargs)
    return decorated_function