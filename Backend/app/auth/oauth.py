from flask import Blueprint,request,jsonify
from backend.app import db
from backend.app.models.user_model import User
from backend.app.utils.tokens import generate_access_token, generate_refresh_token, verify_google_id_token
from backend.app.utils.serializers import serialize_user 


oauth_bp = Blueprint('oauth', __name__)

@oauth_bp.route("/google", methods=["POST"])
def google_login():
  

    data = request.get_json()

    raw_id_token = data.get("id_token")

    if not raw_id_token:
        return jsonify({"error": "ID token missing"}), 400

    # Verify the ID token
    idinfo, error = verify_google_id_token(raw_id_token)
    if error:
        return jsonify({"error": error}), 400


    email = idinfo.get("email")
    name = idinfo.get("name")
    google_id = idinfo.get("sub")  

    if not email:
        return jsonify({"error": "Email not found in ID token"}), 400

    #  Check if user exists, if not create a new user
    user = User.query.filter_by(email=email).first()
    if not user:
        user = User(google_id=google_id, email=email, name=name, provider="google")
        db.session.add(user)
        db.session.commit()
    else:
    # Update user information if necessary
     if user.name != name:
        user.name = name
        db.session.commit()

    # Generate own jwt token for the user
    token = generate_access_token(user.id)
    refresh_token = generate_refresh_token(user.id)
    return jsonify({"access_token": str(token), "refresh_token": str(refresh_token), "user": serialize_user(user)}), 200


