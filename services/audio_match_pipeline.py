import shutil
import os
from uuid import uuid4
from fastapi import UploadFile
from fastapi.responses import JSONResponse
from services.audio_transcriber import transcribe_audio
from services.ayah_matcher import match_transcription_to_ayah
from data_access.quranDAO import normalize_arabic, QURAN_DATA

############## Helpers ##############

def save_uploaded_audio(file: UploadFile, debug_dir: str = "debug_uploads") -> str:
    """Saves the uploaded audio file locally for debugging."""
    os.makedirs(debug_dir, exist_ok=True)
    audio_path = os.path.join(debug_dir, f"raw_{uuid4().hex}.aac")

    with open(audio_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    file.file.seek(0)
    print(f"🔉 Saved uploaded audio to: {audio_path}")
    return audio_path


def is_unwanted_transcription(text: str) -> bool:
    """Returns True if the transcription is an ad or fallback phrase."""
    unwanted_phrases = [
        "اشتركوا في القناة",
        "ترجمة نانسي قنقر",
        "subscribe to the channel"
    ]
    return text.strip().lower() in [p.lower() for p in unwanted_phrases]


def build_full_surah(surah_id: int) -> list[dict]:
    """Builds and returns the full surah (ayahs) for the matched result."""
    return sorted([
        {
            "surah": ayah["surah"],
            "ayah": ayah["ayah"],
            "arabic_text": ayah["text_ar"],
            "translation": ayah["translation"]
        }
        for ayah in QURAN_DATA
        if ayah["surah"] == surah_id and ayah["ayah"] > 0 and ayah["text_ar"].strip()
    ], key=lambda x: x["ayah"])

############## Main Handler ##############

async def transcribe_and_match(file: UploadFile):
    """Main entrypoint: Transcribes an audio file and finds a matching Quran ayah."""

    print("🎯 POST /transcribe2 was hit")

    # Step 1: Save audio locally (debug purposes)
    try:
        save_uploaded_audio(file)
    except Exception as e:
        print("❌ Failed to save audio file:", str(e))

    # Step 2: Transcribe audio
    try:
        raw_transcription = await transcribe_audio(file)
    except Exception as e:
        print("❌ Error during transcription:", str(e))
        return JSONResponse(status_code=500, content={"error": "Transcription failed", "details": str(e)})

    print("🔤 Raw Transcription:", raw_transcription)

    # Step 3: Filter out ad-like fallback transcriptions
    if is_unwanted_transcription(raw_transcription):
        print("❌ Detected unwanted fallback transcription, returning no match")
        return {
            "match_found": False,
            "transcription": "",
            "normalized": ""
        }

    # Step 4: Normalize transcription
    normalized_input = normalize_arabic(raw_transcription)
    print("🔎 Normalized Input:", normalized_input)

    # Step 5: Attempt to match to an ayah
    best_match = match_transcription_to_ayah(normalized_input)

    # Step 6: Format and return result
    if best_match:
        print("✅ Match found:", best_match["text_ar"])
        return {
            "match_found": True,
            "matched_ayah": {
                "surah": best_match["surah"],
                "surah_name": best_match.get("surah_name", f"Surah {best_match['surah']}"),
                "ayah": best_match["ayah"],
                "arabic_text": best_match["text_ar"],
                "translation": best_match["translation"]
            },
            "surah_name": best_match.get("surah_name", f"Surah {best_match['surah']}"),
            "full_surah": build_full_surah(best_match["surah"]),
            "transcription": raw_transcription,
            "normalized": normalized_input
        }

    print("❌ No match found")
    return {
        "match_found": False,
        "transcription": raw_transcription,
        "normalized": normalized_input
    }
