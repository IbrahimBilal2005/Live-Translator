from data_access.quranDAO import QURAN_DATA
from rapidfuzz import fuzz

def is_valid_phrase(phrase: str) -> bool:
    return len(phrase.split()) >= 3

def token_overlap_score(transcribed_tokens, target_text):
    target_tokens = set(target_text.split())
    return sum(1 for token in transcribed_tokens if token in target_tokens)

def match_transcription_to_ayah(normalized_input: str) -> dict | None:
    transcribed_tokens = normalized_input.split()
    best_match = None
    best_combined_score = 0

    for ayah in QURAN_DATA:
        # --- Full ayah comparison ---
        fuzzy_score_full = fuzz.partial_ratio(normalized_input, ayah["normalized_ar"])
        token_score_full = token_overlap_score(transcribed_tokens, ayah["normalized_ar"])
        combined_score_full = fuzzy_score_full + token_score_full * 10  # Tune weight as needed

        if combined_score_full > best_combined_score:
            best_match = ayah
            best_combined_score = combined_score_full

        # --- Start phrase comparison ---
        for phrase in ayah.get("start_phrases", []):
            if is_valid_phrase(phrase):
                fuzzy_score_phrase = fuzz.partial_ratio(normalized_input, phrase)
                token_score_phrase = token_overlap_score(transcribed_tokens, phrase)
                combined_score_phrase = fuzzy_score_phrase + token_score_phrase * 10

                if combined_score_phrase > best_combined_score:
                    best_match = ayah
                    best_combined_score = combined_score_phrase

    return best_match
