import sys, os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from services.search_service import list_surahs, get_surah, get_ayah, search_quran
from data_access.quranDAO import QURAN_DATA, load_quran_data


def test_list_surahs():
    print("📘 All Surahs:")
    for s in list_surahs()[:5]:
        print(s)

def test_get_surah():
    print("\n📗 Surah 1 Ayahs:")
    surah = get_surah(1)
    for a in surah:
        print(f"Ayah {a['ayah']}: {a['text_ar']}")

def test_get_ayah():
    print("\n📙 Specific Ayah - Surah 18, Ayah 1:")
    ayah = get_ayah(18, 1)
    print(ayah)

def test_search():
    print("\n🔍 Search Results for 'الحمد':")
    results = search_quran("الحمد")
    for r in results[:5]:
        print(f"{r['surah']}:{r['ayah']} - {r['text_ar']}")

if __name__ == "__main__":
    QURAN_DATA.clear()  # Clear any existing data
    load_quran_data()  # Load Quran data
    test_list_surahs()
    test_get_surah()
    test_get_ayah()
    test_search()
