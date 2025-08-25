from flask import Blueprint, jsonify, request
from backend.app.utils.tokens import generate_access_token, generate_refresh_token
from backend.app.models.user_model import User
from backend.app import db
from backend.app.utils.serializers import serialize_user

jwt_auth_bp = Blueprint('jwt_auth', __name__)

# POST /api/v1/auth/jwt – Register a new user
@jwt_auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or not data.get('name') or not data.get('password') or not data.get('email'):
        return {"message": "Name, email, and password are required."}, 400

    if User.query.filter_by(email=data['email']).first():
        return {"message": "Email already registered."}, 409

    if User.query.filter_by(name=data['name']).first():
        return {"message": "Name already taken."}, 409

    new_user = User(email=data['email'], name=data['name'], provider='email')
    new_user.set_password(data['password'])
    db.session.add(new_user)
    db.session.commit()

    token = generate_access_token(new_user.id)
    refresh_token = generate_refresh_token(new_user.id)
    return jsonify({"token": str(token), "refresh_token": str(refresh_token), "user": serialize_user(new_user)}), 201


# POST /api/v1/auth/jwt/login – User login and create token
@jwt_auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or not data.get('email') or not data.get('password'):
       return {"message": "Email and password are required."}, 400

    user = User.query.filter_by(email=data['email'], provider='email').first()

    if not user or not user.check_password(data['password']):
        return {"message": "Invalid credentials."}, 401

    token = generate_access_token(user.id)
    refresh_token = generate_refresh_token(user.id)
    return jsonify({"token": str(token), "refresh_token": str(refresh_token), "user": serialize_user(user)}), 200
