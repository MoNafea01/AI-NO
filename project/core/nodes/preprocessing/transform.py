from .preprocessor import Preprocessor
from .fit import Fit
# from .utils import save_data, load_node, get_attributes, handle_name, _get_nodes_dir

# class Transform:
#     def __init__(self, data, preprocessor: dict|str = None):
#         self.preprocessor_path = preprocessor
#         self.preprocessor = preprocessor() if isinstance(preprocessor, Fit) else (preprocessor() 
#                                             if isinstance(preprocessor, Preprocessor) else(preprocessor if isinstance(preprocessor, dict)
#                                             else(int(preprocessor))))
#         self.data = data.get('data') if isinstance(data, dict) else data
        # self.payload = self.transform()

#     def transform(self):
#         if isinstance(self.preprocessor, dict):
#             try:
#                 import joblib
#                 nodes_dir = _get_nodes_dir()
#                 preprocessor = joblib.load(f'{nodes_dir}\\{self.preprocessor.get('node_name')}_{self.preprocessor.get('node_id')}.pkl')
#                 transformed = preprocessor.transform(self.data)
#                 attributes = get_attributes(preprocessor)
#                 payload = {"message": "Data transformed", 
#                            'data': transformed,
#                            "node": preprocessor,
#                            'node_name': self.preprocessor.get('node_name'),
#                            'node_id': self.preprocessor.get('node_id'), 
#                            'attributes': attributes,
#                            }
#                 save_data(payload)
#                 del payload['node']
#                 return payload
#             except Exception as e:
#                 raise ValueError(f"Error loading preprocessor: {e}")
#         try:
#             node_name, node_id = handle_name(self.preprocessor_path)
#             preprocessor = self.preprocessor
#             transformed = preprocessor.transform(self.data)
#             attributes = get_attributes(preprocessor)
#             payload = {"message": "Data transformed", 
#                        'data': transformed, 
#                        "node": preprocessor,
#                        'node_name': node_name, 
#                        'node_id': node_id, 
#                        'attributes': attributes,
#                        }
#             save_data(payload)
#             del payload['node']
#             return payload
#         except Exception as e:
#             raise ValueError(f"Error transforming data: {e}")
        
#     def __str__(self):
#         return str(self.payload)
    
#     def __call__(self,*args):
#         return self.payload

from .preprocessor import Preprocessor
from .fit import Fit
from .utils import PreprocessorAttributeExtractor
from ..utils import NodeLoader, NodeSaver, DataHandler


class PreprocessorTransformer:
    """Handles the transformation of data."""
    def __init__(self, preprocessor, data):
        self.preprocessor = preprocessor
        self.data = data

    def transform_data(self):
        """transform the data with the provided preprocessor."""
        try:
            output = self.preprocessor.transform(self.data)
        except Exception as e:
            raise ValueError(f"Error transforming data: {e}")
        return output

class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, node, data):
        print()
        return {
            "message": message,
            "params": PreprocessorAttributeExtractor.get_attributes(node.__dict__.get("preprocessor")),
            "node_id": id(node),
            "node_name": "transformer",
            "node_data": data,
        }

class Transform:
    """Orchestrates the transformation process."""
    def __init__(self, data, preprocessor=None):
        self.preprocessor = preprocessor
        self.data = DataHandler.extract_data(data)
        self.payload = self._transform()

    def _transform(self):
        if isinstance(self.preprocessor, dict):
            return self._transform_from_id()
        elif isinstance(rf"{self.preprocessor}", str):
            return self._transform_from_path()
        else:
            raise ValueError("Invalid preprocessor or path provided.")

    def _transform_from_id(self):
        try:
            prepocessor = NodeLoader.load(self.preprocessor.get("node_id"))  # Load model using ID from database
            return self._transform_handler(prepocessor)
        except Exception as e:
            raise ValueError(f"Error transformation using preprocessor by ID: {e}")

    def _transform_from_path(self):
        try:
            model = NodeLoader.load(path=self.preprocessor)
            return self._transform_handler(model)
        except Exception as e:
            raise ValueError(f"Error transformation using preprocessor by path: {e}")
    

    def _transform_handler(self, preprocessor):
        try:
            transformer = PreprocessorTransformer(preprocessor, self.data)
            output = transformer.transform_data()
            payload = PayloadBuilder.build_payload("Preprocessor transformed data", transformer, output)
            NodeSaver.save(payload, "core/nodes/saved/data")
            return payload
        except Exception as e:
            raise ValueError(f"Error transformation of data: {e}")
        
    def __str__(self):
        return str(self.payload)

    def __call__(self, *args):
        return self.payload

# if __name__ == '__main__':
#     scaler = Preprocessor("standard_scaler", "scaler", {'with_mean': True, 'with_std': True})
#     fit = Fit([[1, 2], [2, 3]], scaler)
#     # # scaler = r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\backend\core\nodes\saved\preprocessors\standard_3121037534288.pkl"
#     transformed = Transform([[3, 4], [4, 5]], scaler)
#     print(transformed)
