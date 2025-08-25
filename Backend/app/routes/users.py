from flask import Blueprint, jsonify, request
from backend.app import db
from backend.app.models.user_model import User
from backend.app.utils.serializers import serialize_user
from backend.app.utils.decorators import self_access_required, token_required

users_bp = Blueprint('users', __name__)

# GET /api/v1/users – List all users
@users_bp.route('/', methods=['GET'])
@token_required
def get_all_users(user):
    users = User.query.all()
    return jsonify([serialize_user(u) for u in users]), 200

# GET /api/v1/users/me – Get current user info
@users_bp.route('/me', methods=['GET'])
@token_required
def get_current_user(user):
    return jsonify(serialize_user(user)), 200

# PUT /api/v1/users/<user_id> – Update user's name 
@users_bp.route('/<int:user_id>', methods=['PUT'])
@token_required
@self_access_required
def update_user(user, user_id):
    data = request.get_json()
    if not data:
        return {"message": "No data provided."}, 400

    if "email" in data:
        existing_user = User.query.filter_by(email=data["email"]).first()
        if existing_user and existing_user.id != user.id:
            return {"message": "Email already in use."}, 409
        user.email = data["email"]

    if "name" in data:
        user.name = data["name"]

    db.session.commit()

    return {
        "message": "User updated.",
        "user": serialize_user(user)
    }, 200

# DELETE /api/v1/users/<user_id> – Delete user
@users_bp.route('/<int:user_id>', methods=['DELETE'])
@token_required
@self_access_required
def delete_user(user, user_id):
    db.session.delete(user)
    db.session.commit()
    return {"message": "User deleted."}, 200
