import json
from pathlib import Path
import re
import pprint

QURAN_DATA = []

def normalize_arabic(text: str) -> str:
    text = re.sub(r'[\u064B-\u0652\u0670\u06D6-\u06ED]', '', text)
    text = text.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا')
    text = text.replace('ى', 'ي').replace('ة', 'ه')
    text = text.replace('ؤ', 'و').replace('ئ', 'ي')
    text = text.replace('ٱ', 'ا')
    return re.sub(r'\s+', ' ', text).strip()

def load_quran_data():
    global QURAN_DATA
    file_path = Path("data_access/quran_en.json")
    with open(file_path, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    for surah in raw_data:
        surah_id = surah["id"]
        for verse in surah["verses"]:
            text_ar = verse["text"]
            translation = verse["translation"]
            normalized = normalize_arabic(text_ar)
            words = normalized.split()

            start_phrases = []
            for n in range(1, 7):
                for i in range(len(words) - n + 1):
                    start_phrases.append(" ".join(words[i:i+n]))

            QURAN_DATA.append({
                "surah": surah_id,
                "ayah": verse["id"],
                "text_ar": text_ar,
                "translation": translation,
                "normalized_ar": normalized,
                "word_count": len(words),
                "start_phrases": start_phrases
            })

def get_all_ayahs():
    return QURAN_DATA

def print_sample_ayahs(n: int = 5):
    if not QURAN_DATA:
        print("❌ QURAN_DATA is empty. Did you forget to call load_quran_data()?")

    print(f"🔍 Showing first {n} ayah entries in QURAN_DATA:\n")
    for i, ayah in enumerate(QURAN_DATA[:n], start=1):
        print(f"\n📖 Ayah #{i}")
        pprint.pprint(ayah, width=140)
        print("-" * 100)

def get_ayah_data(surah_id: int, ayah_id: int):
    """ Return all data for a specific ayah from QURAN_DATA. """
    for ayah in QURAN_DATA:
        if ayah["surah"] == surah_id and ayah["ayah"] == ayah_id:
            return {
                "surah": ayah["surah"],
                "ayah": ayah["ayah"],
                "text_ar": ayah["text_ar"],
                "translation": ayah["translation"],
                "normalized_ar": ayah["normalized_ar"],
                "word_count": ayah["word_count"],
                "start_phrases": ayah["start_phrases"]
            }
    return None

if __name__ == "__main__":
    QURAN_DATA.clear()  # Clear any existing data
    load_quran_data()
    aya_info = get_ayah_data(4, 1)  # Example to get data for Surah Al-Kahf, Ayah 1
    print(aya_info)
