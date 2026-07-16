import logging
import os

from app.core.config import settings

logger = logging.getLogger(__name__)

if settings.debug:
    SAVING_DIR = "core/test_saved"
else:
    SAVING_DIR = "core/saved"

base_dir = os.path.dirname(os.path.abspath(__file__))
