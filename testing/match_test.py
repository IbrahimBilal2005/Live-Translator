import json
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from services.matching_service import match_transcription_to_ayah
from data_access.quranDAO import load_quran_data, QURAN_DATA

def simulate_transcribe2_from_normalized(normalized_input: str):
    print("🎤 Simulating /transcribe2 endpoint with normalized input...\n")
    print(f"🔤 Normalized input: {normalized_input}")

    # Step 1: Match ayah
    matched = match_transcription_to_ayah(normalized_input)

    # Step 2: Build response
    if matched:
        matched_surah_id = matched['surah']

        full_surah = sorted([
            {
                "surah": ayah["surah"],
                "ayah": ayah["ayah"],
                "arabic_text": ayah["text_ar"],
                "translation": ayah["translation"]
            }
            for ayah in QURAN_DATA
            if ayah["surah"] == matched_surah_id and ayah["ayah"] > 0 and ayah["text_ar"].strip()
        ], key=lambda x: x["ayah"])

        response = {
            "match_found": True,
            "matched_ayah": {
                "surah": matched["surah"],
                "surah_name": matched.get("surah_name", f"Surah {matched['surah']}"),
                "ayah": matched["ayah"],
                "arabic_text": matched["text_ar"],
                "translation": matched["translation"]
            },
            "surah_name": matched.get("surah_name", f"Surah {matched['surah']}"),
            "full_surah": full_surah,
            "transcription": "<you supplied normalized input>",
            "normalized": normalized_input
        }
    else:
        response = {
            "match_found": False,
            "transcription": "<you supplied normalized input>",
            "normalized": normalized_input
        }

    print("\n📦 Simulated Response:")
    print(json.dumps(response, ensure_ascii=False, indent=2))

# === MAIN ===
if __name__ == "__main__":
    load_quran_data()

    # 🧪 Example: replace with any normalized input
    normalized_test_input = "فلم يزدهم دعآءيٓ الا فرارٗا"
    simulate_transcribe2_from_normalized(normalized_test_input)
