from fastapi import APIRouter
from data_access.quranDAO import get_all_ayahs

router = APIRouter()

@router.get("/ayahs")
def debug_ayahs():
    """Return count and sample of Ayahs with 15+ words (for debugging)."""
    ayahs = get_all_ayahs()
    long_ayahs = [a for a in ayahs if a["word_count"] >= 15]
    
    return {
        "count": len(long_ayahs), 
        "sample": long_ayahs[:3]
    }