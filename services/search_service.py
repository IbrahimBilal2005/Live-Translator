from data_access.quranDAO import QURAN_DATA

def list_surahs():
    """ Returns a list of all surahs in the Quran with their IDs and number of ayahs."""
    surahs = {}
    for ayah in QURAN_DATA:
        sid = ayah["surah"]
        if sid not in surahs:
            surahs[sid] = {"id": sid, "ayahs": 0}
        surahs[sid]["ayahs"] += 1
    return list(surahs.values())

def get_surah(surah_id: int):
    """ Returns all ayahs for a given surah ID."""
    return [a for a in QURAN_DATA if a["surah"] == surah_id]

def get_ayah(surah_id: int, ayah_id: int):
    """ Retrieves a specific ayah by surah and ayah ID."""
    return next((a for a in QURAN_DATA if a["surah"] == surah_id and a["ayah"] == ayah_id), None)

def search_quran(query: str):
    """ Searches the Quran for normalized ayahs containing the given query string."""
    query = query.strip().lower()
    results = []
    for ayah in QURAN_DATA:
        if query in ayah["normalized_ar"].lower() or query in ayah["translation"].lower():
            results.append(ayah)
    return results
