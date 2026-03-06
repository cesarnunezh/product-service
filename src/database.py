import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker


def env_bool(name: str, default: bool = False) -> bool:
    val = os.getenv(name)
    if val is None:
        return default
    return val.strip().lower() in {"1", "true", "t", "yes", "y", "on"}


DATABASE_URL = os.getenv("DATABASE_URL")
DEV = env_bool("DEV", default=True)

engine = None
AsyncSessionLocal = None


def get_engine():
    global engine
    if engine is None:
        engine = create_async_engine(DATABASE_URL, echo=DEV, future=True)
    return engine


def get_session_local():
    global AsyncSessionLocal
    if AsyncSessionLocal is None:
        AsyncSessionLocal = sessionmaker(
            get_engine(),
            class_=AsyncSession,
            expire_on_commit=False,
        )
    return AsyncSessionLocal


async def get_db():
    session_local = get_session_local()
    async with session_local() as session:
        yield session
