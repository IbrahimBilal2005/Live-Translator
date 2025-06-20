import os
from tempfile import NamedTemporaryFile
from fastapi import UploadFile
from openai import OpenAI
from pydub import AudioSegment
from dotenv import load_dotenv

# Load environment variables from project root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../.env"))

# Initialize OpenAI client with API key from environment variables
api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=api_key)


def trim_audio(input_path: str, duration_ms: int = 5000) -> str:
    """Trim the audio file to a specified duration and save it."""
    print("✅ Trimming to 5 seconds...")
    
    audio = AudioSegment.from_file(input_path)
    trimmed_audio = audio[:duration_ms]
    trimmed_path = input_path.replace(".mp3", "_trimmed.mp3")
    trimmed_audio.export(trimmed_path, format="mp3")
    
    print("✅ Audio trimmed to 5 seconds:", trimmed_path)
    return trimmed_path


def send_to_whisper(audio_path: str) -> str:
    """Send an audio file to OpenAI Whisper and return the transcription."""
    print("✅ Sending trimmed audio to Whisper...")
    with open(audio_path, "rb") as audio_file:
        transcript = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
            response_format="text",
            language="ar"
        )
    print("✅ Transcription complete")
    return transcript.strip()


async def transcribe_audio(file: UploadFile) -> str:
    """Transcribes the first 5 seconds of an uploaded audio file.
    
    Steps:
    - Save uploaded file to a temp file
    - Trim to 5 seconds
    - Transcribe with Whisper
    - Clean up temp files
    """
    print("✅ Received file:", file.filename)

    with NamedTemporaryFile(delete=False, suffix=".mp3") as temp:
        content = await file.read()
        temp.write(content)
        temp_path = temp.name

    trimmed_path = trim_audio(temp_path)

    try:
        return send_to_whisper(trimmed_path)
    finally:
        os.remove(temp_path)
        if os.path.exists(trimmed_path):
            os.remove(trimmed_path)
        print("🧹 Cleaned up temp files")
