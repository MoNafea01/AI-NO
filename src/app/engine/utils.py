import os
import re
import uuid

import numpy as np


class NodeNameHandler:
    """Handles naming and ID extraction from paths."""

    @staticmethod
    def handle_name(path=None):
        if not path:
            raise ValueError("Path must be provided.")
        name = path.split("/")[-1].split("\\")[-1].split(".")[0]
        _name = re.sub(r"\d+", "", name)
        _id = re.sub(r"\D", "", name)
        _id = _id if _id else 0
        _name = _name.rsplit("_", 1)[0]
        return _name, int(_id)


class PayloadBuilder:
    """Constructs payloads for saving and response."""

    @staticmethod
    def build_payload(message, node_data, node_name, **kwargs):
        payload = {
            "message": message,
            "node_id": uuid.uuid4().int & ((1 << 63) - 1),
            "node_name": node_name,
            "node_data": node_data,
            "task": "custom",
        }
        payload.update(kwargs)
        return payload


def load_data(path: str) -> tuple[np.array, np.array, dict[str, int]]:
    """Load images, resize, normalize, and encode labels."""
    try:
        import cv2
    except ImportError:
        raise ImportError("opencv-python (cv2) is required for image loading.")

    def _load_imgs(img_path: str) -> list[str]:
        dirs = os.listdir(img_path)
        imgs = []
        labels = []
        for folder in dirs:
            for img in os.listdir(os.path.join(img_path, folder)):
                img_path_full = os.path.join(img_path, folder, img)
                imgs.append(img_path_full)
                labels.append(folder)
        return imgs, labels

    def _label_encoding(labels: list[str]) -> tuple[list[int], dict[str, int]]:
        label_dict = {k: v for v, k in enumerate(np.unique(labels))}
        encoded_labels = [label_dict[label] for label in labels]
        return encoded_labels, label_dict

    imgs, labels = _load_imgs(path)
    encoded_labels, label_dict = _label_encoding(labels)
    img_arr = []
    for img in imgs:
        img = cv2.imread(img)
        img = cv2.resize(img, (150, 150))
        img = img / 255
        img_arr.append(img)
    img_arr = np.array(img_arr)
    encoded_labels = np.array(encoded_labels)
    return img_arr, encoded_labels, label_dict
