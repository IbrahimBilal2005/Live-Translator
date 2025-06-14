import shutil
import os
from uuid import uuid4
from fastapi import UploadFile
from fastapi.responses import JSONResponse
from services.transcribe_audio_service import transcribe_audio
from services.matching_service import match_transcription_to_ayah
from data_access.quranDAO import normalize_arabic, QURAN_DATA

async def transcribe_and_match(file: UploadFile):
    """Handles the transcription of an audio file and matches the transcription to a Quran ayah."""
    
    print("🎯 POST /transcribe2 was hit")

    # ✅ Step 0: Save uploaded audio for debugging
    try:
        debug_dir = "debug_uploads"
        os.makedirs(debug_dir, exist_ok=True)
        raw_audio_path = os.path.join(debug_dir, f"raw_{uuid4().hex}.aac")

        with open(raw_audio_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        print(f"🔉 Saved uploaded audio to: {raw_audio_path}")

        # Reset file pointer for later use
        file.file.seek(0)
    except Exception as e:
        print("❌ Failed to save audio file:", str(e))

    # Step 1: Transcribe the uploaded audio
    try:
        raw_transcription = await transcribe_audio(file)
    except Exception as e:
        print("❌ Error during transcription:", str(e))
        return JSONResponse(status_code=500, content={"error": "Transcription failed", "details": str(e)})

    print("🔤 Raw Transcription:", raw_transcription)

    # Step 1.5: Check for unwanted fallback phrases
    UNWANTED_PHRASES = [
        "اشتركوا في القناة",
        "ترجمة نانسي قنقر",
        "subscribe to the channel",
        # Add other unwanted phrases here if needed
    ]
    if raw_transcription.strip().lower() in [p.lower() for p in UNWANTED_PHRASES]:
        print("❌ Detected unwanted fallback transcription, returning no match")
        return {
            "match_found": False,
            "transcription": "",
            "normalized": ""
        }

    # Step 2: Normalize the transcription
    normalized_input = normalize_arabic(raw_transcription)
    print("🔎 Normalized Input:", normalized_input)

    # Step 3: Match transcription to ayah
    best_match = match_transcription_to_ayah(normalized_input)

    # Step 4: Return result
    if best_match:
        print("✅ Match found:", best_match["text_ar"])

        matched_surah_id = best_match["surah"]
        full_surah = sorted([
            {
                "surah": ayah["surah"],  # ✅ Add this
                "ayah": ayah["ayah"],
                "arabic_text": ayah["text_ar"],
                "translation": ayah["translation"]
            }
            for ayah in QURAN_DATA
            if ayah["surah"] == matched_surah_id and ayah["ayah"] > 0 and ayah["text_ar"].strip()
        ], key=lambda x: x["ayah"])


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
            "full_surah": full_surah,
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
