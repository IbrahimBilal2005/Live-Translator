import os
from dotenv import load_dotenv
from fastapi import UploadFile
from tempfile import NamedTemporaryFile
from openai import OpenAI
from pydub import AudioSegment

# Load environment variables from .env file located at project root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../.env"))

# Retrieve OpenAI API key from environment
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise ValueError("❌ OPENAI_API_KEY not found in environment")

# Initialize OpenAI client
client = OpenAI(api_key=api_key)

async def transcribe_audio(file: UploadFile) -> str:
    """ Transcribes the first 5 seconds of an audio file using OpenAI's Whisper model."""
    
    print("📥 Received file:", file.filename)

    # Save uploaded file to a temporary location
    with NamedTemporaryFile(delete=False, suffix=".mp3") as temp:
        content = await file.read()
        temp.write(content)
        temp_path = temp.name

    try:
        print("✂️ Trimming to 5 seconds...")
        audio = AudioSegment.from_file(temp_path)
        trimmed_audio = audio[:5000]  # Trim to first 5 seconds (2000ms)

        # Export the trimmed audio to a new temp file
        trimmed_path = temp_path.replace(".mp3", "_trimmed.mp3")
        trimmed_audio.export(trimmed_path, format="mp3")
    
        print("🔁 Sending trimmed audio to Whisper...")
        with open(trimmed_path, "rb") as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                response_format="text",
                language="ar"  # Arabic language
            )

        print("✅ Transcription complete")
        return transcript.strip()

    finally:
        # Ensure all temp files are deleted
        os.remove(temp_path)
        if os.path.exists(trimmed_path):
            os.remove(trimmed_path)
        print("🧹 Cleaned up temp files")
