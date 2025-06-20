import json
import re
import pprint
from pathlib import Path

QURAN_DATA = []

# Path to Quran JSON file
QURAN_JSON_PATH = Path("data_access/quran_en.json")

def normalize_arabic(text: str) -> str:
    """
    Normalize Arabic text for matching by removing diacritics and standardizing characters.
    """
    text = re.sub(r'[\u064B-\u0652\u0670\u06D6-\u06ED]', '', text)
    text = text.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا')
    text = text.replace('ى', 'ي').replace('ة', 'ه')
    text = text.replace('ؤ', 'و').replace('ئ', 'ي').replace('ٱ', 'ا')
    return re.sub(r'\s+', ' ', text).strip()

def load_quran_data():
    """
    Load the Quran data from JSON and populate QURAN_DATA with normalized and enriched entries.
    """
    global QURAN_DATA
    QURAN_DATA.clear()

    with open(QURAN_JSON_PATH, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    for surah in raw_data:
        surah_id = surah["id"]
        surah_name = surah["name"]
        for verse in surah["verses"]:
            text_ar = verse["text"]
            translation = verse["translation"]
            normalized = normalize_arabic(text_ar)
            words = normalized.split()

            # Generate phrase fragments of up to 6 words
            start_phrases = [
                " ".join(words[i:i+n])
                for n in range(1, 7)
                for i in range(len(words) - n + 1)
            ]

            QURAN_DATA.append({
                "surah": surah_id,
                "surah_name": surah_name,
                "ayah": verse["id"],
                "text_ar": text_ar,
                "translation": translation,
                "normalized_ar": normalized,
                "word_count": len(words),
                "start_phrases": start_phrases
            })

def get_all_ayahs():
    """Return the full list of loaded ayahs."""
    return QURAN_DATA

def get_ayah_data(surah_id: int, ayah_id: int):
    """
    Return a specific ayah from QURAN_DATA.
    """
    for ayah in QURAN_DATA:
        if ayah["surah"] == surah_id and ayah["ayah"] == ayah_id:
            return {
                "surah": ayah["surah"],
                "surah_name": ayah["surah_name"],
                "ayah": ayah["ayah"],
                "text_ar": ayah["text_ar"],
                "translation": ayah["translation"],
                "normalized_ar": ayah["normalized_ar"],
                "word_count": ayah["word_count"],
                "start_phrases": ayah["start_phrases"]
            }
    return None

def get_all_surahs() -> list[dict]:
    """
    Extract top-level Surah information from Quran JSON file.
    """
    with open(QURAN_JSON_PATH, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    return sorted([
        {
            "id": surah["id"],
            "name": surah["name"],
            "transliteration": surah.get("transliteration", ""),
            "translation": surah.get("translation", "")
        }
        for surah in raw_data
    ], key=lambda x: x["id"])

def print_sample_ayahs(n: int = 5):
    """
    Print the first N ayahs from QURAN_DATA for inspection.
    """
    if not QURAN_DATA:
        print("❌ QURAN_DATA is empty. Did you forget to call load_quran_data()?")

    print(f"🔍 Showing first {n} ayah entries:\n")
    for i, ayah in enumerate(QURAN_DATA[:n], start=1):
        print(f"\n📖 Ayah #{i}")
        pprint.pprint(ayah, width=140)
        print("-" * 100)

if __name__ == "__main__":
    load_quran_data()
    print_sample_ayahs(3)
    print(get_ayah_data(71, 6))
