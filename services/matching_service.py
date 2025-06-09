from data_access.quranDAO import QURAN_DATA
from rapidfuzz import fuzz

def is_valid_phrase(phrase: str) -> bool:
    return len(phrase.split()) >= 3

def match_transcription_to_ayah(normalized_input: str) -> dict | None:
    """
    Use fuzzy matching to find the best matching ayah or start phrase.
    """
    best_match = None
    highest_score = 0
    THRESHOLD = 70  # You can fine-tune this

    for ayah in QURAN_DATA:
        # Compare with full normalized ayah
        score_full = fuzz.partial_ratio(normalized_input, ayah["normalized_ar"])
        if score_full > highest_score and score_full >= THRESHOLD:
            best_match = ayah
            highest_score = score_full

        # Compare with valid start phrases
        for phrase in ayah.get("start_phrases", []):
            if is_valid_phrase(phrase):
                score_phrase = fuzz.partial_ratio(normalized_input, phrase)
                if score_phrase > highest_score and score_phrase >= THRESHOLD:
                    best_match = ayah
                    highest_score = score_phrase

    return best_match
