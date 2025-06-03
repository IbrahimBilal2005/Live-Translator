from fastapi import APIRouter
from data_access.quran_repository import get_all_ayahs

router = APIRouter()

@router.get("/debug/ayahs")
def get_sample_ayahs():
    ayahs = get_all_ayahs()
    # Show long ayahs with short start phrase (<=5 words)
    long_ayahs = [a for a in ayahs if a['word_count'] >= 15 and len(a['start_phrase'].split()) <= 5]
    return {
        "count": len(long_ayahs),
        "sample": long_ayahs[:3]
    }

