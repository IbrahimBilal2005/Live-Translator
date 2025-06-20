from fastapi import APIRouter, HTTPException
from typing import List, Dict
from services.search_service import get_surah_by_number, get_all_surahs, get_random_ayah

router = APIRouter()


@router.get("/surahs")
def list_surahs() -> List[Dict]:
    """Return all Surahs."""
    return get_all_surahs()


@router.get("/surahs/{surah_id}")
def get_surah(surah_id: int) -> Dict:
    """Return a Surah by ID."""
    surah = get_surah_by_number(surah_id)
    if not surah:
        raise HTTPException(status_code=404, detail="Surah not found")
    return surah


@router.get("/random-ayah")
def random_ayah() -> Dict:
    """Return a random Ayah."""
    ayah = get_random_ayah()
    return {
        "surah": ayah["surah"],
        "surah_name": ayah["surah_name"],
        "ayah": ayah["ayah"],
        "text_ar": ayah["text_ar"],
        "translation": ayah["translation"],
    }
