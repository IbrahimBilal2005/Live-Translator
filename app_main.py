from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os
from fastapi.responses import JSONResponse


from transcribe import transcribe_audio
from quran_repository import load_quran_data, normalize_arabic, QURAN_DATA, print_sample_ayahs

print("🕋 Loading Quran data...")
QURAN_DATA.clear()  # Clear any existing data
load_quran_data()
print("✅ Quran data loaded!")

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
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


@app.post("/transcribe2")
async def transcribe_and_match(file: UploadFile = File(...)):
    print("🎯 POST /transcribe2 was hit")

    try:
        raw_transcription = await transcribe_audio(file)
    except Exception as e:
        print("❌ Transcription error:", str(e))
        return JSONResponse(status_code=500, content={"error": "Transcription failed", "details": str(e)})

    print("🔤 Raw Transcription:", raw_transcription)
    normalized_input = normalize_arabic(raw_transcription)
    print("🔎 Normalized Input:", normalized_input)

    best_match = None

    # Phase 1: Exact full ayah match
    for ayah in QURAN_DATA:
        if normalized_input == ayah["normalized_ar"]:
            best_match = ayah
            print("✅ Full ayah match found")
            break

    # Phase 2: Phrase match with minimum 3-word phrases
    if not best_match:
        for ayah in QURAN_DATA:
            for phrase in ayah.get("start_phrases", []):
                if len(phrase) < 3:
                    continue  # ⛔ skip short phrases
                if phrase in normalized_input:
                    best_match = ayah
                    print(f"✅ Matched phrase: {phrase}")
                    break
            if best_match:
                break

    if best_match:
        return {
            "match_found": True,
            "matched_ayah": {
                "surah": best_match["surah"],
                "ayah": best_match["ayah"],
                "arabic_text": best_match["text_ar"],
                "translation": best_match["translation"]
            },
            "transcription": raw_transcription,
            "normalized": normalized_input
        }
    else:
        print("❌ No match found")
        return {
            "match_found": False,
            "transcription": raw_transcription,
            "normalized": normalized_input
        }
  

if __name__ == "__main__":
    QURAN_DATA.clear()  # Clear any existing data
    load_quran_data()
    print_sample_ayahs(5)  # Print sample ayahs for debugging