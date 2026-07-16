"""Core configuration settings for the AI-NO application."""

from functools import lru_cache
from pathlib import Path

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

ENV_FILE_PATH = Path(__file__).parent.parent / ".env"


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=str(ENV_FILE_PATH),
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="allow",
    )

    # Application
    app_name: str = "AI-NO"
    app_version: str = "1.0.0"
    debug: bool = True
    environment: str = Field(default="development", alias="ENV")

    FILE_MAX_SIZE_MB: int = 50
    FILE_ALLOWED_TYPES: list[str] = ["application/json", "text/csv"]
    FILE_STORAGE_PATH: str = "data/files"
    FILE_DEFAULT_CHUNK_SIZE: int = 524288

    # API
    allowed_hosts: list[str] = ["*"]

    # CORS
    cors_origins: list[str] = ["http://localhost:3000", "http://localhost:8000"]
    cors_allow_credentials: bool = True
    cors_allow_methods: list[str] = ["*"]
    cors_allow_headers: list[str] = ["*"]

    # Database – PostgreSQL
    POSTGRES_USERNAME: str = "postgres"
    POSTGRES_PASSWORD: str = ""
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    POSTGRES_MAIN_DB: str = "aino_db"

    # Security
    secret_key: str = Field(
        default="CHANGE_THIS_SECRET_KEY_IN_PRODUCTION",
        alias="SECRET_KEY",
    )
    algorithm: str = "HS256"
    access_token_expire_minutes: int = Field(default=30, alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    refresh_token_expire_days: int = Field(default=7, alias="REFRESH_TOKEN_EXPIRE_DAYS")

    # AI Services
    GENERATION_BACKEND: str = "GROQ"
    EMBEDDING_BACKEND: str = "COHERE"

    OPENAI_API_KEY: str | None = None
    COHERE_API_KEY: str | None = None
    GROQ_API_KEY: str | None = None
    BASE_API_URL: str | None = None

    GENERATION_MODEL_ID: str | None = None
    EMBEDDING_MODEL_ID: str | None = None
    EMBEDDING_MODEL_SIZE: int | None = None

    DEFAULT_GENERATION_TEMPERATURE: float = 0.1
    DEFAULT_GENERATION_OUTPUT_MAX_TOKENS: int = 512
    DEFAULT_GENERATION_INPUT_MAX_CHARACTERS: int = 4096

    # Vector DB
    VECTOR_DB_BACKEND: str = "QDRANT"
    VECTOR_DB_PATH: str = "data/database"
    VECTOR_DB_PATH_NAME: str = "qdrant_db"
    VECTOR_DB_DISTANCE_METRIC: str | None = "cosine"

    QDRANT_HOST: str | None = "localhost"
    QDRANT_PORT: int = 6333

    PRIMARY_LANGUAGE: str = "en"
    DEFAULT_LANGUAGE: str = "en"

    # Celery
    CELERY_BROKER_URL: str | None = None
    CELERY_RESULT_BACKEND: str | None = None
    CELERY_TASK_SERIALIZER: str = "json"
    CELERY_RESULT_SERIALIZER: str = "json"
    CELERY_ACCEPT_CONTENT: list[str] = ["json"]
    CELERY_TASK_TIME_LIMIT: int = 600
    CELERY_ACKS_LATE: bool = True
    CELERY_WORKER_CONCURRENCY: int = 2
    CELERY_BEAT_SCHEDULE_INTERVAL: int | None = None
    CELERY_BEAT_RETENTION_TIME: int | None = None

    # Logging
    log_level: str = "INFO"
    log_format: str = "json"

    # Redis
    redis_url: str | None = Field(default=None, alias="REDIS_URL")

    @field_validator("cors_origins", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: str | list[str]) -> list[str] | str:
        """Parse CORS origins from environment variable."""
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, list | str):
            return v
        raise ValueError(v)


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


# Singleton instance
settings = get_settings()
