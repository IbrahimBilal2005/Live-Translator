from data_access.quranDAO import QURAN_DATA
from rapidfuzz import fuzz

def is_valid_phrase(phrase: str) -> bool:
    """Return True if the phrase has at least 3 words."""
    return len(phrase.split()) >= 3

def token_overlap_score(transcribed_tokens: list[str], target_text: str) -> int:
    """
    Count how many words from the transcription appear in the target text.
    This is used to improve scoring beyond fuzzy matching alone.
    """
    target_tokens = set(target_text.split())
    return sum(1 for token in transcribed_tokens if token in target_tokens)

def match_transcription_to_ayah(normalized_input: str) -> dict | None:
    """
    Match normalized Arabic transcription to the best-fitting Quran ayah.
    Combines fuzzy matching and word overlap to improve accuracy.

    Args:
        normalized_input (str): Transcribed text (normalized Arabic).

    Returns:
        dict | None: The best-matching ayah, or None if no good match is found.
    """
    transcribed_tokens = normalized_input.split()
    best_match = None
    best_score = 0

    for ayah in QURAN_DATA:
        # Match against full ayah text
        fuzzy_score = fuzz.partial_ratio(normalized_input, ayah["normalized_ar"])
        token_score = token_overlap_score(transcribed_tokens, ayah["normalized_ar"])
        total_score = fuzzy_score + token_score * 10  # Token match is weighted higher

        if total_score > best_score:
            best_match = ayah
            best_score = total_score

        # Also check start phrases if available
        for phrase in ayah.get("start_phrases", []):
            if is_valid_phrase(phrase):
                fuzzy_score = fuzz.partial_ratio(normalized_input, phrase)
                token_score = token_overlap_score(transcribed_tokens, phrase)
                total_score = fuzzy_score + token_score * 10

                if total_score > best_score:
                    best_match = ayah
                    best_score = total_score

    return best_match
