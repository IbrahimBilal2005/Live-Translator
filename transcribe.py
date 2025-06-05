import os
from dotenv import load_dotenv
from fastapi import UploadFile
from tempfile import NamedTemporaryFile
from openai import OpenAI
from pydub import AudioSegment

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))
api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    raise ValueError("❌ OPENAI_API_KEY not found in environment")

client = OpenAI(api_key=api_key)

async def transcribe_audio(file: UploadFile) -> str:
    print("📥 Received file:", file.filename)

    with NamedTemporaryFile(delete=False, suffix=".mp3") as temp:
        content = await file.read()
        temp.write(content)
        temp_path = temp.name

    try:
        print("✂️ Trimming to 2 seconds...")
        audio = AudioSegment.from_file(temp_path)
        trimmed_audio = audio[:2000]

        trimmed_path = temp_path.replace(".mp3", "_trimmed.mp3")
        trimmed_audio.export(trimmed_path, format="mp3")

        print("🔁 Sending trimmed audio to Whisper...")
        with open(trimmed_path, "rb") as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                response_format="text",
                language="ar"
            )

        print("✅ Transcription complete")
        return transcript.strip()

    finally:
        os.remove(temp_path)
        if os.path.exists(trimmed_path):
            os.remove(trimmed_path)
        print("🧹 Cleaned up temp files")
