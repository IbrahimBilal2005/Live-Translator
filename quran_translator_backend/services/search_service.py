from data_access.quranDAO import QURAN_DATA
import json
from pathlib import Path

def get_surah(surah_id: int):
    """ Returns all ayahs for a given surah ID."""
    return [a for a in QURAN_DATA if a["surah"] == surah_id]

def get_surah_by_number(surah_number: int) -> dict | None:
    ayahs = [ayah for ayah in QURAN_DATA if ayah["surah"] == surah_number]
    if not ayahs:
        return None

    return {
        "surah": surah_number,
        "surah_name": ayahs[0].get("surah_name", ""),
        "ayahs": ayahs
    }

def get_all_surahs() -> list[dict]:
    file_path = Path("data_access/quran_en.json")
    with open(file_path, "r", encoding="utf-8") as f:
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
