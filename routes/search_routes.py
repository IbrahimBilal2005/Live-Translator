from fastapi import APIRouter, HTTPException
from services.search_service import get_surah_by_number, get_all_surahs, get_random_ayah
from pydantic import BaseModel

router = APIRouter()

class SurahRequest(BaseModel):
    surah_number: int

@router.get("/surahs")
def api_list_surahs():
    """List all Surahs in the Quran."""
    result = get_all_surahs()
    print("🧾 Returning surah list:", result[:3])  # Print first 3 entries only

    return result

@router.get("/surahs/{surah_id}")
def api_get_surah(surah_id: int):
    """Get a specific Surah by its ID."""
    surah = get_surah_by_number(surah_id)
    if not surah:
        raise HTTPException(status_code=404, detail="Surah not found")
    return surah

@router.get("/random-ayah")
def api_get_random_ayah():
    """Return a truly random ayah."""
    ayah = get_random_ayah()
    return {
        "surah": ayah["surah"],
        "surah_name": ayah["surah_name"],
        "ayah": ayah["ayah"],
        "text_ar": ayah["text_ar"],
        "translation": ayah["translation"]
    }
    
