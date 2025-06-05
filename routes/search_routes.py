from fastapi import APIRouter, HTTPException
from services.search_service import list_surahs, get_surah, get_ayah, search_quran

router = APIRouter()

@router.get("/surahs")
def api_list_surahs():
    return list_surahs()

@router.get("/surahs/{surah_id}")
def api_get_surah(surah_id: int):
    surah = get_surah(surah_id)
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
