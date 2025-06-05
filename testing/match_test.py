from data_access.quranDAO import load_quran_data, normalize_arabic, QURAN_DATA

import sys, os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

def match_ayah(input_text):
    normalized_input = normalize_arabic(input_text)
    print(f"🔤 Normalized Input: '{normalized_input}'")

    for ayah in QURAN_DATA:
        if normalized_input == ayah["normalized_ar"]:
            return ayah
        for phrase in ayah.get("start_phrases", []):
            if normalized_input == phrase:
                return ayah
    return None

# Load Quran data
load_quran_data()

# Test input
input_text =  "الذي خلقكم من"
result = match_ayah(input_text)

if result:
    print("✅ Match Found:")
    print(f"Ayah {result['ayah']} from Surah {result['surah']}")
    print(f"Arabic: {result['text_ar']}")
    print(f"Translation: {result['translation']}")
else:
    print("❌ No match found.")


