from fastapi import APIRouter, UploadFile, File
from fastapi.responses import JSONResponse
from services.transcribe_service import transcribe_and_match

router = APIRouter()

@router.post("/transcribe2")
async def post_transcription(file: UploadFile = File(...)):
    return await transcribe_and_match(file)
