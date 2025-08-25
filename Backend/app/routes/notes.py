from flask import Blueprint, jsonify, request
from backend.app.utils.serializers import serialize_note
from backend.app.models.note_model import Note
from backend.app import db
from backend.app.utils.decorators import token_required, owner_required


notes_bp = Blueprint('notes', __name__)

# GET /api/v1/notes – List all notes for the verified token user
@notes_bp.route('/', methods=['GET'])
@token_required
def get_notes(user):
    notes = Note.query.filter_by(user_id=user.id).all()
    return jsonify([serialize_note(note) for note in notes]), 200

# POST /api/v1/notes – Create a new note
@notes_bp.route('/', methods=['POST'])
@token_required
def add_note(user):
    data = request.get_json()

    if not data or not data.get("title") or not data.get("content"):
        return {"message": "Title and content are required."}, 400

    new_note = Note(
        title=data["title"],
        content=data.get("content"),
        user_id=user.id
    )

    db.session.add(new_note)
    db.session.commit()

    return {
        "message": "Note created.",
        "note": serialize_note(new_note)
    }, 201

# GET /api/v1/notes/<id> – Get note by ID
@notes_bp.route('/<int:note_id>', methods=['GET'])
@token_required
@owner_required
def get_note_by_id(user, note_id):
    note = request.note
    return jsonify(serialize_note(note)), 200

# PUT /api/v1/notes/<id> – Update a note
@notes_bp.route('/<int:note_id>', methods=['PUT'])
@token_required
@owner_required
def update_note(user, note_id):
    note = request.note
    data = request.get_json()
    if not data:
        return {"message": "No data provided."}, 400

    if "title" in data:
        note.title = data["title"]

    if "content" in data:
        note.content = data["content"]

    db.session.commit()

    return {
        "message": "Note updated.",
        "note": serialize_note(note)
    }, 200

# DELETE /api/v1/notes/<id> – Delete a note
@notes_bp.route('/<int:note_id>', methods=['DELETE'])
@token_required
@owner_required
def delete_note(user, note_id):
    note = request.note
    db.session.delete(note)
    db.session.commit()
    return {"message": "Note deleted."}, 200