from data_access.quranDAO import QURAN_DATA

def is_valid_phrase(phrase: str) -> bool:
    """Only consider phrases with 3 or more words for matching."""
    return len(phrase.split()) >= 3

def match_transcription_to_ayah(normalized_input: str) -> dict | None:
    """
    Try to find the best ayah match for the given normalized input.
    Prioritizes exact substrings, then falls back to longer start phrases.
    """
    for ayah in QURAN_DATA:
        if normalized_input in ayah["normalized_ar"]:
            return ayah
        for phrase in ayah["start_phrases"]:
            if is_valid_phrase(phrase) and phrase in normalized_input:
                return ayah
    return None