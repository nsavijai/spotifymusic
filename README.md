# 🎵 VMusic

> A modern full-stack music streaming application built with **Flutter** and **FastAPI**, featuring secure authentication, real-time music streaming, playlist management, and a scalable Clean Architecture.

---

## ✨ Overview

VMusic is a production-oriented music streaming application inspired by modern streaming platforms. It follows **Feature-First Clean Architecture**, separating presentation, business logic, and data layers to ensure maintainability, scalability, and testability.

---

## 🚀 Features

### 👤 Authentication
- User Registration
- Secure Login
- JWT Authentication
- Refresh Token Support
- Forgot Password
- Reset Password
- Change Password
- Persistent Login
- Protected Routes

### 🎵 Music
- Browse Songs
- Albums
- Artists
- Playlists
- Search Music
- Music Streaming
- Mini Player
- Full Screen Player
- Queue Management
- Shuffle & Repeat

### 📚 Library
- Liked Songs
- Recently Played
- Playlist Management
- Listening History
- Favorites

### 👤 User
- View Profile
- Edit Profile
- Update Avatar
- Secure Logout

### ⚡ User Experience
- Dark Theme
- Responsive UI
- Smooth Animations
- Offline Detection
- Loading & Empty States
- Global Error Handling

---

# 🏗️ Architecture

```
Flutter
│
├── Presentation
├── Riverpod Providers
├── Repositories
├── Remote Data Sources
├── Dio HTTP Client
│
▼
FastAPI
│
├── API Routes
├── Services
├── Repositories
├── SQLAlchemy
│
▼
PostgreSQL
```

Both frontend and backend follow **Clean Architecture** and the **Repository Pattern**.

---

# 🛠️ Tech Stack

## Frontend

- Flutter
- Dart
- Riverpod
- Go Router
- Dio
- Flutter Secure Storage
- Freezed
- JSON Serializable
- Cached Network Image
- just_audio
- Material 3

## Backend

- FastAPI
- Python
- PostgreSQL
- SQLAlchemy Async
- Alembic
- JWT Authentication
- Passlib (bcrypt)
- Pydantic
- Uvicorn

---

# 📂 Project Structure

```
vmusic/

├── frontend/
│   └── lib/
│       ├── core/
│       ├── features/
│       ├── routes/
│       └── shared/
│
└── backend/
    ├── app/
    │   ├── core/
    │   ├── features/
    │   ├── database/
    │   └── main.py
    └── requirements.txt
```

---

# 🔐 Authentication Flow

```
Splash
    │
    ▼
Check Secure Storage
    │
    ▼
Access Token Available?
    │
 ┌──┴─────┐
 │        │
Yes       No
 │         │
 ▼         ▼
Refresh    Login
Token      Register
 │
 ▼
Home
```

---

# 🎵 Music Flow

```
Flutter

      │

      ▼

FastAPI

      │

      ▼

Music Provider

      │

      ▼

Audio Stream

      │

      ▼

just_audio Player
```

---

# 🚀 Getting Started

## Clone Repository

```bash
git clone https://github.com/your-username/vmusic.git
cd vmusic
```

---

## Frontend

```bash
cd frontend
flutter pub get
flutter run
```

---

## Backend

```bash
cd backend

python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS/Linux
source .venv/bin/activate

pip install -r requirements.txt

uvicorn app.main:app --reload
```

---

# 📱 Screens

- Splash
- Login
- Register
- Home
- Search
- Albums
- Artists
- Playlists
- Library
- Profile
- Settings
- Music Player

---

# 📈 Roadmap

- [x] Authentication
- [x] Profile Management
- [x] Music Streaming
- [x] Playlist Management
- [x] Search
- [x] Library
- [ ] Offline Downloads
- [ ] Push Notifications
- [ ] Premium Features
- [ ] AI Music Recommendations

---

# 🤝 Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch

```bash
git checkout -b feature/my-feature
```

3. Commit your changes

```bash
git commit -m "Add new feature"
```

4. Push to your branch

```bash
git push origin feature/my-feature
```

5. Open a Pull Request

---

# 📄 License

This project is licensed under the MIT License.

---

# 👨‍💻 Author

**Vijai N S A**

- GitHub: https://github.com/VijaiCoder
- LinkedIn: https://www.linkedin.com/in/vijai-nsa-753b05260

---

⭐ If you found this project helpful, consider giving it a star on GitHub!
