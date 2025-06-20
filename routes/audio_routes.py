from fastapi import APIRouter, UploadFile, File
from services.audio_match_pipeline import transcribe_and_match

router = APIRouter() 

@router.post("/transcribe2")
async def post_transcription(file: UploadFile = File(...)):
    """Transcribe audio and match it with a Quranic verse."""
    return await transcribe_and_match(file)