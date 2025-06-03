import json
from pathlib import Path
import re

QURAN_DATA = []

def normalize_arabic(text: str) -> str:
    # Remove tashkeel (diacritics and Quran-specific marks)
    text = re.sub(r'[\u064B-\u0652\u0670\u06D6-\u06ED]', '', text)

    # Normalize characters
    text = text.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا')
    text = text.replace('ى', 'ي').replace('ة', 'ه')
    text = text.replace('ؤ', 'و').replace('ئ', 'ي')
    text = text.replace('ٱ', 'ا')  # Alef Wasla → regular Alef

    # Strip extra spaces
    return re.sub(r'\s+', ' ', text).strip()



def load_quran_data():
    global QURAN_DATA
    file_path = Path("data_access/quran_en.json")

    with open(file_path, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    # 🔍 Loop through each surah
    for surah in raw_data:
        surah_name = surah["name"]
        surah_id = surah["id"]
        for verse in surah["verses"]:
            text_ar = verse["text"]
            translation = verse["translation"]
            normalized = normalize_arabic(text_ar)
            QURAN_DATA.append({
                "surah": surah_id,
                "ayah": verse["id"],
                "text_ar": text_ar,
                "translation": translation,
                "normalized_ar": normalized,
                "word_count": len(text_ar.split()),
                "start_phrase": " ".join(normalized.split()[:6])
            })

def get_all_ayahs():
    return QURAN_DATA
