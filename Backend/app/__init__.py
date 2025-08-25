from flask import Flask
from .config import Config
from .db import db

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)

    from .auth.jwt_auth import jwt_auth_bp
    from .auth.oauth import oauth_bp
    from .routes.notes import notes_bp
    from .routes.users import users_bp
    from .auth.refresh_routes import refresh_bp

    app.register_blueprint(jwt_auth_bp, url_prefix='/api/v1/auth/jwt')
    app.register_blueprint(oauth_bp, url_prefix='/api/v1/auth/oauth')
    app.register_blueprint(refresh_bp, url_prefix='/api/v1/auth')
    app.register_blueprint(notes_bp, url_prefix='/api/v1/notes')
    app.register_blueprint(users_bp, url_prefix='/api/v1/users')

    return app


