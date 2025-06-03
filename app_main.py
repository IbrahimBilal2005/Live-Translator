from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from interface_adapters.transcribe import transcribe_audio  # ← your function in transcribe.py
import os
from dotenv import load_dotenv

from data_access.quran_repository import load_quran_data
from interface_adapters.api_routes import router as api_router

print("🕋 Loading Quran data...")
load_quran_data()
print("✅ Quran data loaded!")


# Load environment variables
load_dotenv()

app = FastAPI()

# Allow frontend connections
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this later
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("🚨 app_main.py LOADED!")
print(f"🔐 OpenAI key loaded: {bool(os.getenv('OPENAI_API_KEY'))}")

@app.get("/")
def read_root():
    print("✅ GET / was hit")
    return {"message": "Hello from Quran API"}

@app.post("/test")
async def test_upload(file: UploadFile = File(...)):
    print("🎯 POST /test was hit")
    return {"filename": file.filename}

from fastapi import APIRouter
from data_access.quran_repository import get_all_ayahs

router = APIRouter()

app.include_router(api_router)


@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    print("🎙️ POST /transcribe was hit")
    try:
        text = await transcribe_audio(file)
        return {"transcription": text}
    except Exception as e:
        return {"error": str(e)}
