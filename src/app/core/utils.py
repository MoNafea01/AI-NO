"""Shared utility functions."""

import os
import random
import re
import string

from pydantic import BaseModel


def get_clean_file_name(filename: str) -> str:
    """Sanitize a filename by removing unwanted characters."""
    cleaned = re.sub(r"[^\w.]", "_", filename.strip())
    return cleaned.replace(" ", "_")


def generate_random_string(length: int = 12) -> str:
    """Generate a random alphanumeric string."""
    chars = string.ascii_letters + string.digits
    return "".join(random.choice(chars) for _ in range(length))


def generate_unique_filepath(
    original_filename: str, project_path: str
) -> dict[str, str]:
    """Generate a unique file path for storing uploads."""
    random_str = generate_random_string()
    original_filename = get_clean_file_name(original_filename)

    while True:
        file_path = os.path.join(project_path, f"{random_str}_{original_filename}")
        if not os.path.exists(file_path):
            break
        random_str = generate_random_string()

    return {
        "filename": original_filename,
        "path": file_path,
        "prefix": random_str,
    }


def is_empty(value) -> bool:
    """Recursively determine if a value is empty."""
    if value in (None, "", [], {}, 0, "0"):
        return True
    if isinstance(value, dict):
        return all(is_empty(v) for v in value.values())
    if isinstance(value, list | tuple | set):
        return all(is_empty(v) for v in value)
    return False

class NodeGUIMeta(BaseModel):
    """Metadata for visual editor GUI."""
    component_id: int
    displayed_name: str = ""
    location_x: float = 0.0
    location_y: float = 0.0
    inputs: list[int] | None = []
    outputs: list[int] | None = []

class NodePort(BaseModel):
    _id: int
    name: str
    type: str  # "input" or "output"
    description: str | None = ""

class NodeModel(BaseModel):
    node_id: int
    node_name: str
    payload: dict
    params: dict
    task: str
    type: str
    project_id: int
    gui_meta: NodeGUIMeta
    in_ports: list[NodePort]
    out_ports: list[NodePort]
