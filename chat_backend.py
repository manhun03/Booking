from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

import chat_service
from chat_controller import router as chat_router


app = FastAPI(title="TravelBuddy Chat Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup() -> None:
    chat_service.init_chat_db()


app.include_router(chat_router)


def run() -> None:
    uvicorn.run("chat_backend:app", host="0.0.0.0", port=8000, reload=True)


if __name__ == "__main__":
    run()
