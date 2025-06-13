from fastapi import APIRouter, HTTPException
from services.search_service import get_ayah, search_quran  # Keep only what's needed
from services.surah_service import get_surah_by_number, get_all_surahs

router = APIRouter()

@router.get("/surahs")
def api_list_surahs():
    result = get_all_surahs()
    print("🧾 Returning surah list:", result[:3])  # Print first 3 entries only

    return result

@router.get("/surahs/{surah_id}")
def api_get_surah(surah_id: int):
    surah = get_surah_by_number(surah_id)
    if not surah:
        raise HTTPException(status_code=404, detail="Surah not found")
    return surah

@router.get("/surahs/{surah_id}/ayahs/{ayah_id}")
def api_get_ayah(surah_id: int, ayah_id: int):
    ayah = get_ayah(surah_id, ayah_id)
    if not ayah:
        raise HTTPException(status_code=404, detail="Ayah not found")
    return ayah

@router.get("/search")
def api_search_quran(q: str):
    results = search_quran(q)
    return {"count": len(results), "results": results}


