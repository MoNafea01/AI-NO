# from .preprocessor import Preprocessor
# from .utils import save_data, save_node, load_node, get_attributes, handle_name, _get_nodes_dir

class FitTransform:
    def __init__(self, data, preprocessor: dict | str = None):
        self.preprocessor_path = preprocessor
        self.preprocessor = preprocessor() if isinstance(preprocessor, int) else (preprocessor if isinstance(preprocessor, dict)
                                      else (preprocessor))
        self.data = data.get('data') if isinstance(data, dict) else data
        self.payload = self.fit_transform()

#     def fit_transform(self):
#         if isinstance(self.preprocessor, dict):
#             try:
#                 import joblib
#                 nodes_dir = _get_nodes_dir()
#                 preprocessor = joblib.load(f'{nodes_dir}\\{self.preprocessor.get('node_name')}_{self.preprocessor.get('node_id')}.pkl')
#                 if hasattr(preprocessor, 'fit_transform'):
#                     transformed_data = preprocessor.fit_transform(self.data)
#                     attributes = get_attributes(preprocessor)
#                     payload = {
#                         "message": "Data fitted and transformed",
#                         "node": preprocessor,
#                         'node_name': self.preprocessor.get('node_name'),
#                         'node_id': self.preprocessor.get('node_id'),
#                         'attributes': attributes,
#                         'data': transformed_data
#                     }
#                     save_node(payload)
#                     save_data(payload)
#                     del payload['node']
#                     return payload
#             except Exception as e:
#                 raise ValueError(f"Error fitting and transforming preprocessor: {e}")
#         try:
#             node_name, node_id = handle_name(self.preprocessor_path)
#             transformed_data = self.preprocessor.fit_transform(self.data)
#             attributes = get_attributes(self.preprocessor)
#             payload = {
#                 "message": "Data fitted and transformed",
#                 "node": self.preprocessor,
#                 'node_name': node_name,
#                 'node_id': node_id,
#                 'attributes': attributes,
#                 'data': transformed_data
#             }
#             save_node(payload)
#             save_data(payload)
#             del payload['node']
#             return payload
#         except Exception as e:
#             raise ValueError(f"Error fitting and transforming data: {e}")

#     def __str__(self):
#         return str(self.payload)

#     def __call__(self, *args):
#         return self.payload


# if __name__ == '__main__':
#     import numpy as np
#     data = np.array([[1, 2], [2, 3]])
#     scaler = Preprocessor("standard_scaler",'scaler', {'with_mean': True, 'with_std': True})
#     # scaler = r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\backend\core\nodes\saved\preprocessors\standard_2186793224480.pkl"
#     fit_transform = FitTransform(data, scaler)
#     print(fit_transform)