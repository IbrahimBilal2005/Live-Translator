from fastapi import FastAPI
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from data_access.quranDAO import load_quran_data, QURAN_DATA
from api_routes import register_routes

load_dotenv() # Load environment variables from .env file
load_quran_data() # Load Quran data into memory

app = FastAPI() 

# Configure CORS middleware to allow requests from any origin
# TODO Render endpoint config 
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
    """Basic root endpoint for testing the API."""
    return {"message": "Hello from Quran Translator API"}
