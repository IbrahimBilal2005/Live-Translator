# 🛠️ Project Setup Guide: Quran Live Translator

This guide walks you through setting up both the backend (FastAPI) and the frontend (Flutter) components of the Quran Live Translator project.

---

## ✅ Prerequisites

Before starting, make sure you have the following installed:

- [Python 3.10+](https://www.python.org/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Git](https://git-scm.com/)
- Code editor (e.g., VS Code)

---

## 📦 1. Clone the Repository

Open a terminal and run:

```bash
git clone https://github.com/IbrahimBilal2005/QuranLive.git
```

---

## 🖥️ 2. Backend Setup (FastAPI + Uvicorn)

```bash
cd QuranLive   # Navigate into the backend folder

# Create and activate the Python virtual environment
python -m venv venv
.\venv\Scripts\activate      # Use 'source venv/bin/activate' on Mac/Linux

# Install required dependencies
pip install -r requirements.txt

# Create a .env file with your OpenAI API key
echo OPENAI_API_KEY=your-api-key-here > .env

# Run the FastAPI backend server
uvicorn app_main:app --reload
```

The backend will be accessible at:  
👉 http://127.0.0.1:8000

---

## 📱 3. Frontend Setup (Flutter)

> 🔁 Open a **new terminal window** (keep the backend running)

```bash
cd frontend

# Clean old builds and fetch dependencies
flutter clean
flutter pub get

# Run the Flutter app on your emulator or connected device
flutter run

# If you're using a real phone or iOS simulator, run with your local IP:
flutter run --dart-define=API_BASE_URL=http://<your-ip>:8000

```

- To stop the backend or frontend in the terminal, press `Ctrl + C`.
- In Flutter:
  - Press `r` in the terminal for a **hot reload**
  - Press `R` in the terminal for a **hot restart**

---

## 📄 Notes

- Ask the project owner (Ibrahim) for the actual `.env` file or OpenAI API key.
- Do **not commit `.env`** to the repo. It's already listed in `.gitignore`.
- If you want to update dependencies later:

```bash
pip freeze > requirements.txt
```
