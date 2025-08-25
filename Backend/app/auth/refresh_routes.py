from flask import Blueprint, request, jsonify
from backend.app import db
from backend.app.utils.tokens import generate_access_token, verify_refresh_token, rotate_refresh_token

refresh_bp = Blueprint("refresh", __name__)

@refresh_bp.route("/refresh", methods=["POST"])
def refresh():
    data = request.get_json()
    raw_token = data.get("refresh_token")
    
    if not raw_token :
        return jsonify({"error": "Missing refresh token"}), 400

    db_token, error = verify_refresh_token(raw_token)
    if error:
        return jsonify({"error": error}), 401

    new_refresh_token= rotate_refresh_token(db_token)
    new_access_token = generate_access_token(db_token.user_id)

    return jsonify({
        "access_token": new_access_token,
        "refresh_token": new_refresh_token,
        
    }), 200

@refresh_bp.route("/logout", methods=["POST"])
def logout():
    data = request.get_json()
    raw_token = data.get("refresh_token")
   
    if not raw_token:
        return jsonify({"error": "Missing refresh token"}), 400

    # verify token
    db_token, error = verify_refresh_token(raw_token)
    if error:
        return jsonify({"error": error}), 401

    # Revoke the token
    db_token.revoked = True
    db.session.commit()

    return jsonify({"message": "Logout successful"}), 200
