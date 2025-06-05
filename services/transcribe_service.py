from fastapi import UploadFile
from fastapi.responses import JSONResponse
from services.transcribe_audio_service import transcribe_audio
from services.matching_service import match_transcription_to_ayah
from data_access.quranDAO import normalize_arabic

async def transcribe_and_match(file: UploadFile):
    """Handles the transcription of an audio file and matches the transcription to a Quran ayah."""
    
    print("🎯 POST /transcribe2 was hit")

    # Step 1: Transcribe the uploaded audio
    try:
        raw_transcription = await transcribe_audio(file)
    except Exception as e:
        print("❌ Error during transcription:", str(e))
        return JSONResponse(status_code=500, content={"error": "Transcription failed", "details": str(e)})

    print("🔤 Raw Transcription:", raw_transcription)

    # Step 2: Normalize the transcription
    normalized_input = normalize_arabic(raw_transcription)
    print("🔎 Normalized Input:", normalized_input)

    # Step 3: Match transcription to ayah
    best_match = match_transcription_to_ayah(normalized_input)

    # Step 4: Return result
    if best_match:
        print("✅ Match found:", best_match["text_ar"])
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
        
