"""Celery application configuration for AI-NO."""

import os

# Suppress TensorFlow warnings before any TF import
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import logging
import sys
from pathlib import Path

# Ensure app package is importable
project_root = Path(__file__).parent.parent
if str(project_root) not in sys.path:
    sys.path.insert(0, str(project_root))

from celery import Celery

from app.core.config import get_settings

logger = logging.getLogger("celery.worker")
settings = get_settings()

# Create Celery application
celery_app = Celery(
    "aino",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=[
        "app.tasks.workflow",
    ],
)

# Configure Celery
celery_app.conf.update(
    task_serializer=settings.CELERY_TASK_SERIALIZER,
    result_serializer=settings.CELERY_RESULT_SERIALIZER,
    accept_content=settings.CELERY_ACCEPT_CONTENT,
    task_acks_late=settings.CELERY_ACKS_LATE,
    task_time_limit=settings.CELERY_TASK_TIME_LIMIT,
    task_ignore_result=False,
    result_expires=3600,
    worker_concurrency=settings.CELERY_WORKER_CONCURRENCY,
    broker_connection_retry_on_startup=True,
    broker_connection_retry=True,
    broker_connection_max_retries=10,
    worker_cancel_long_running_tasks_on_connection_loss=True,
    task_routes={
        "app.tasks.workflow.execute_workflow": {"queue": "workflow_queue"},
    },
    timezone="UTC",
)

celery_app.conf.default_queue = "default"
