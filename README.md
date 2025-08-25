# Note App

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue)
![Python](https://img.shields.io/badge/Python-Backend-yellow)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blueviolet)

**Full-Stack Note-Taking Application** built with **Flutter (Frontend)** and **Flask + PostgreSQL (Backend)**.
It allows users to securely **sign up, log in, and manage notes** (create, update, delete).

Authentication features include:

* **JWT Access Tokens** – short-lived (\~15 minutes)
* **Refresh Token Rotation** – secure session management
* **Google OAuth 2.0 Login**
* **Token Reuse Detection & Global Session Invalidation**

---

## Features

### Frontend (Flutter)

* Clean Architecture + **BLoC** state management
* Secure token storage using **Secure Storage**
* **Dio Interceptor** for automatic token refresh without user intervention
* Login / Signup (Email + Password)
* Google OAuth 2.0 login
* Full note CRUD (create, list, update, delete)
* Centralized **API & OAuth constants** in `ApiConstants`

### Backend (Flask + PostgreSQL)

* REST API architecture
* JWT authentication & refresh token rotation
* Token reuse detection + global session revocation
* PostgreSQL with SQLAlchemy
* Google OAuth integration
* Layered project structure (models, routes, utils)

---

## 📂 Project Structure

### Flutter

```
lib/
│
├── core/
│   ├── constants/
│   ├── error/
│   ├── network/
│   └── secure_storage.dart
│
├── features/
│   └── auth/
│       ├── bloc/
│       │   ├── auth_bloc.dart
│       │   ├── auth_event.dart
│       │   └── auth_state.dart
│       │
│       ├── data/
│       │   ├── models/
│       │   ├── auth_remote_data_source.dart
│       │   └── auth_repository.dart
│       │
│       └── notes/
│
├── presentation/
│  ├── pages/
│  ├── widgets/
└── main.dart
```
### Backend (Flask)

```
Backend/
│
├── app/
│   │
│   ├── auth/
│   ├── models/
│   ├── routes/
│   ├── utils/
│   ├── __init__.py
│   ├── config.py
│   ├── create_db.py
│   └── db.py
├── requirements.txt
└── run.py
            
```
---

## Setup & Installation

### Backend

#### 1. Environment Variables
To configure the project, create a `.env` file inside `backend/`.

You can use the provided example.env file as a template:

```env
cp example.env .env
```
Make sure your .env file is not committed to version control. Add it to .gitignore.

#### 2. Run Backend

```bash
# Go to project root
cd note_app

# Create database tables
python -m backend.app.create_db

# Start the backend server
$env:PYTHONPATH="."
python backend/run.py
```

The backend server will be available at:`http://127.0.0.1:5000`.

---

### Frontend (Flutter)

#### 1. Google OAuth Configuration

Android → Add inside `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.gms.client_id"
    android:value="575822625117-0a9m52llu5etlpu6bu0jucv96933flia.apps.googleusercontent.com"/>
```

iOS → Add inside `ios/Runner/Info.plist`:

```xml
<key>GIDClientID</key>
<string>575822625117-0a9m52llu5etlpu6bu0jucv96933flia.apps.googleusercontent.com</string>
```

#### 2. Run Frontend

```bash
cd note_app

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🔐 Authentication Flow

### Email + Password Login

1. User enters email + password in `LoginPage`.
2. Bloc → Repository → API call (`/auth/login`).
3. Backend returns access + refresh token.
4. Tokens are securely stored using **Secure Storage**.
5. Dio interceptor automatically refreshes expired access tokens without user intervention.

### Google OAuth Login

1. User taps **Login with Google**.
2. GoogleSignIn retrieves ID token using `ApiConstants.googleServerClientId`.
3. ID token sent to backend → verified.
4. Backend issues JWT access + refresh tokens.
5. App continues with the same token flow.

---

## API Endpoints

### Auth

| Method | Endpoint        | Description                    |
| ------ | --------------- | ------------------------------ |
| POST   | `/auth/signup`  | Create new user                |
| POST   | `/auth/login`   | Login with email & password    |
| POST   | `/auth/google`  | Login with Google OAuth        |
| POST   | `/auth/refresh` | Refresh access token           |
| POST   | `/auth/logout`  | Logout & revoke refresh tokens |

### Notes

| Method | Endpoint     | Description                |
| ------ | ------------ | -------------------------- |
| GET    | `/notes`     | Get all notes for the user |
| POST   | `/notes`     | Create a new note          |
| PUT    | `/notes/:id` | Update note by ID          |
| DELETE | `/notes/:id` | Delete note by ID          |

---

## Tech Stack

* **Frontend**: Flutter, BLoC, Dio, Secure Storage
* **Backend**: Python (Flask), SQLAlchemy, PostgreSQL, JWT
* **Auth**: JWT, Refresh Token Rotation, Google OAuth 2.0

---

## Demo
| Login Page | Notes List | Note Detail |
|------------|------------|-------------|
| ![Login](frontend/assets/screenshots/login_page_image.png) | ![Notes](frontend/assets/screenshots/notes_image.png) | ![Detail](frontend/assets/screenshots/note_detail_image.png) |

---

Designed with **scalable full-stack architecture** principles.

---

