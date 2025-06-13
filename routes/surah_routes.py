from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.surah_service import get_surah_by_number, get_all_surahs

router = APIRouter()

class SurahRequest(BaseModel):
    surah_number: int

@router.post("/get_surah")
def get_surah(request: SurahRequest):
    result = get_surah_by_number(request.surah_number)
    if not result:
        raise HTTPException(status_code=404, detail="Surah not found")
    return result

@router.get("/surah_list")
def surah_list():
    result = get_all_surahs()
    print("🧾 Returning surah list:", result[:3])  # Print first 3 entries only

    return result

