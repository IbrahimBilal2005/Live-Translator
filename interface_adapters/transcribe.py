import os
from dotenv import load_dotenv
from fastapi import UploadFile
from tempfile import NamedTemporaryFile
from openai import OpenAI

# ✅ Load .env file from the project root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# ✅ Initialize OpenAI client
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise ValueError("❌ OPENAI_API_KEY not found in environment")

client = OpenAI(api_key=api_key)

async def transcribe_audio(file: UploadFile) -> str:
    print("📥 Received file:", file.filename)

    # Save uploaded file temporarily
    with NamedTemporaryFile(delete=False, suffix=".mp3") as temp:
        content = await file.read()
        print(f"📄 File size: {len(content)} bytes")
        temp.write(content)
        temp_path = temp.name

    try:
        print("🔁 Sending to OpenAI Whisper...")
        with open(temp_path, "rb") as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                response_format="text",
                language="ar"
            )
        print("✅ Transcription received")
        return transcript.strip()
    except Exception as e:
        print("❌ Whisper API failed:", e)
        raise e
    finally:
        os.remove(temp_path)
        print("🧹 Temp file deleted")
