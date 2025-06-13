from fastapi import FastAPI
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from data_access.quranDAO import load_quran_data, QURAN_DATA
from api_routes import register_routes

load_dotenv()
QURAN_DATA.clear()
load_quran_data()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

register_routes(app)

@app.get("/")
def root():
    return {"message": "Hello from Quran Translator API"}
