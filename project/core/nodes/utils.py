import os, re, cv2, numpy as np
from ai_operations.models import Node
from core.nodes.configs.const_ import (
    MODELS_TASKS, PREPROCESSORS_TASKS, NN_TASKS, DATA_HANDLER_TASKS, NN_NAMES, MODELS_NAMES, PREPROCESSORS_NAMES, DATA_HANDLER_NAMES)
from .configs.const_ import MODELS_NAMES, PREPROCESSORS_NAMES

class NodeNameHandler:
    """Handles naming and ID extraction from paths."""
    @staticmethod
    def handle_name(path=None):
        if not path:
            raise ValueError("Path must be provided.")
        name = path.split("/")[-1].split(".")[0]
        _name = re.sub(r'\d+', '', name)
        _id = re.sub(r'\D', '', name)
        _id = _id if _id else 0
        _name = _name.rsplit("_", 1)[0]
        return _name, int(_id)



class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, node_data, node_name, **kwargs):
        payload = {
            "message": message,
            "node_id": id(node_data),
            "node_name": node_name,
            "node_data": node_data,
            "task": "custom",
            "children": [],
        }
        if node_name in MODELS_NAMES:
            payload["params"] = ModelAttributeExtractor.get_attributes(node_data)
        elif node_name in PREPROCESSORS_NAMES:
            payload["params"] = PreprocessorAttributeExtractor.get_attributes(node_data)
        else:
            payload["params"] = NodeAttributeExtractor.get_attributes(node_data)
            
        payload.update(kwargs)
        return payload



class NodeAttributeExtractor:
    """Extracts attributes from a node."""
    @staticmethod
    def get_attributes(node):
        attributes = {}
        for attr in dir(node):
            if attr.endswith("_") and not attr.startswith("_"):
                atr = getattr(node, attr)
                if hasattr(atr, "tolist"):
                    attributes[attr] = atr.tolist()
        return attributes



class ModelAttributeExtractor:
    """Extracts attributes from a model."""
    @staticmethod
    def get_attributes(model):
        fitted_params = {}
        attributes = ['coef_', 'intercept_', 'classes_', 
                      'support_vectors_', 'feature_importances_',
                      'tree_', 'n_iter_']
        for attr in attributes:
            if hasattr(model, attr):
                atr = getattr(model, attr)
                if hasattr(atr, 'tolist'):
                    fitted_params[attr] = atr.tolist()
        return fitted_params



class PreprocessorAttributeExtractor:
    """Extracts attributes from a preprocessors."""
    @staticmethod
    def get_attributes(preprocessor):

        excluded_attributes = {
            "n_samples_seen_",
            "n_features_in_",
            "feature_names_in_",
            "dtype_",
            "sparse_input_"
        }
        
        attributes = {}
        for attr in dir(preprocessor):
            if attr.endswith("_") and not attr.startswith("_") and attr not in excluded_attributes:
                atr = getattr(preprocessor, attr)
                if hasattr(atr, "tolist"):
                    attributes[attr] = atr.tolist()
        return attributes



class FolderHandler:
    """Handles folder assignment based on task or node name."""
    @staticmethod
    def get_folder_by_task(task):
        return "model" if task in MODELS_TASKS else (
            "preprocessoring" if task in PREPROCESSORS_TASKS else (
                "nets" if task in NN_TASKS else (
                    "other" if task in DATA_HANDLER_TASKS else "other"
                    )
                )
            )

    @staticmethod
    def get_folder_by_node_name(node_name):
        return "model" if node_name in MODELS_NAMES else (
            "preprocessoring" if node_name in PREPROCESSORS_NAMES else (
                "nets" if node_name in NN_NAMES else (
                    "other" if node_name in DATA_HANDLER_NAMES else "other"
                    )
                )
            )

def delete_node(node: Node):
    node_path = node.node_data
    if os.path.exists(node_path):
        os.remove(node_path)
    node.delete()


def load_imgs(path: str) -> list[str]:
    """
    Params:
    - path : str : The Path of the dataset
    This Function takes the default Path of the dataset and returns the list of images and their labels
    Note the Images are the Pathe of the images
    return:
    - imgs : List[str] : List of the images
    """

    dirs = os.listdir(path)
    imgs = []
    labels = []
    for folder in dirs:
        for img in os.listdir(os.path.join(path, folder)):
            img_path = os.path.join(path, folder, img)
            imgs.append(img_path)
            labels.append(folder)
    return imgs, labels

def label_encoding(labels: list[str]) -> tuple[list[int], dict[str, int]]:
    """
    Params:
    - labels : List[str] : List of the labels
    This function takes the list of labels and returns the encoded labels and the label dictionary
    return:
    - encoded_labels : List[int] : List of the encoded labels
    - label_dict : Dict[str, int] : Dictionary of the labels and their encoded values
    """

    label_dict = {k:v for v,k in enumerate(np.unique(labels))}
    encoded_labels = [label_dict[label] for label in labels]
    return encoded_labels, label_dict

def load_data(path: str) -> tuple[np.array, np.array, dict[str, int]]:

    """

    Params:
    - path : str : The Path of the dataset

    This function takes the path of the dataset and returns the images, encoded labels and the label dictionary
    Note that Images are the numpy array of the images

    return:
    - img_arr : np.array : Numpy array of the images
    - encoded_labels : np.array : Numpy array of the encoded labels
    - label_dict : Dict[str, int] : Dictionary of the labels and their encoded values

    """
    imgs, labels = load_imgs(path)
    encoded_labels, label_dict = label_encoding(labels)
    img_arr = []
    for img in imgs:
        img = cv2.imread(img)
        img = cv2.resize(img, (150,150))
        img = img/255
        img_arr.append(img)
    img_arr = np.array(img_arr)
    encoded_labels = np.array(encoded_labels)
    return img_arr, encoded_labels, label_dict
