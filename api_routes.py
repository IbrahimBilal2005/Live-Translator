from fastapi import FastAPI
from routes.audio_routes import router as audio_router
from routes.search_routes import router as search_router
from routes.debug_routes import router as debug_router

def register_routes(app: FastAPI):
    app.include_router(audio_router, prefix="/audio")
    app.include_router(search_router, prefix="/quran")
    app.include_router(debug_router, prefix="/debug")
