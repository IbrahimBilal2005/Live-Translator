from data_access.quranDAO import QURAN_DATA
from rapidfuzz import fuzz

def is_valid_phrase(phrase: str) -> bool:
    """Return True if the phrase has at least 3 words."""
    return len(phrase.split()) >= 3

def token_match_features(transcribed_tokens: list[str], target_text: str) -> tuple[int, int]:
    """
    Returns:
    - match_count: how many tokens from input are in the target
    - missing_count: how many input tokens are missing from the target
    """
    target_tokens = set(target_text.split())
    match_count = sum(1 for token in transcribed_tokens if token in target_tokens)
    missing_count = sum(1 for token in transcribed_tokens if token not in target_tokens)
    return match_count, missing_count

def ending_similarity(transcribed_tokens: list[str], target_text: str) -> int:
    """
    Score based on how many of the final tokens in the transcription match the final tokens of the candidate ayah.
    """
    target_tokens = target_text.split()
    input_end = transcribed_tokens[-3:] if len(transcribed_tokens) >= 3 else transcribed_tokens
    target_end = target_tokens[-3:] if len(target_tokens) >= 3 else target_tokens
    return sum(1 for token in input_end if token in target_end)

def compute_score(input_text: str, target_text: str, tokens: list[str], ayah: dict) -> float:
    """
    Assign a weighted score to the similarity between transcription and ayah.
    Factors considered:
    - fuzzy string match
    - token-based similarity
    - rare/missing token match
    - ending similarity boost
    - slight bonus for first ayahs in surahs
    """
    fuzzy = fuzz.partial_ratio(input_text, target_text)  # general partial string match
    token_ratio = fuzz.token_set_ratio(input_text, target_text) # full token similarity
    match_count, missing_count = token_match_features(tokens, target_text) # boost for overlap, penalize for mismatches
    end_similarity_score = ending_similarity(tokens, target_text) # extra boost for matching endings

    score = (
        0.45 * fuzzy + 
        0.25 * token_ratio +
        0.2 * (match_count * 10 - missing_count * 10) +
        0.1 * end_similarity_score * 10
    )

    if ayah.get("ayah", 0) == 1:
        score += 5 # small bonus if it's the first ayah of a surah

    return score

def match_transcription_to_ayah(normalized_input: str) -> dict | None:
    """
    Given a normalized Arabic transcription, find the most likely matching ayah.
    Tries both the full ayah text and its listed start phrases (if any).
    """
    tokens = normalized_input.split()
    best_match = None
    best_score = 0

    for ayah in QURAN_DATA:
        # Score the match against the full ayah
        score = compute_score(normalized_input, ayah["normalized_ar"], tokens, ayah)

        if score > best_score:
            best_score = score
            best_match = ayah
        
        # Also check all of its predefined start phrases (for better matching early parts)
        for phrase in ayah.get("start_phrases", []):
            if is_valid_phrase(phrase):
                phrase_score = compute_score(normalized_input, phrase, tokens, ayah)
                if phrase_score > best_score:
                    best_score = phrase_score
                    best_match = ayah

    # Require a minimum score to avoid bad matches from weak input
    min_threshold = len(tokens) * 8 + 30
    return best_match if best_score >= min_threshold else None
