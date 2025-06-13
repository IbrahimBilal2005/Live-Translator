from fastapi import APIRouter, HTTPException
from services.search_service import get_surah_by_number, get_all_surahs
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