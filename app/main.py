from contextlib import asynccontextmanager
from fastapi import FastAPI
from sqlmodel import  SQLModel

from dependencies import engine
from routers import members, expenses

@asynccontextmanager
async def lifespan(app: FastAPI):
    SQLModel.metadata.create_all(engine)
    yield


app = FastAPI()
app.include_router(members.router)
app.include_router(expenses.router)

@app.get("/")
async def root():
    return {"message": "Hello World"}
