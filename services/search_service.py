from data_access.quranDAO import QURAN_DATA, get_all_surahs as _get_all_surahs
import random
from typing import List, Dict


def get_surah(surah_id: int) -> List[Dict]:
    """Return all ayahs for a given Surah ID."""
    return [a for a in QURAN_DATA if a["surah"] == surah_id]


def get_surah_by_number(surah_number: int) -> Dict | None:
    """Return a Surah by number, including metadata and all Ayahs."""
    ayahs = [ayah for ayah in QURAN_DATA if ayah["surah"] == surah_number]
    if not ayahs:
        return None

    return {
        "surah": surah_number,
        "surah_name": ayahs[0].get("surah_name", ""),
        "ayahs": ayahs,
    }


def get_random_ayah() -> Dict | None:
    """Return a random Ayah from the Quran dataset."""
    if not QURAN_DATA:
        return None
    return random.choice(QURAN_DATA)


def get_all_surahs() -> List[Dict]:
    """Return all Surahs with metadata (delegated to DAO)."""
    return _get_all_surahs()
