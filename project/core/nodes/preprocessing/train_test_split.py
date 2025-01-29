from sklearn.model_selection import train_test_split
from ..utils import DataHandler

class TrainTestSplit:
    def __init__(self, data, params=None):
        self.data = DataHandler.extract_data(data)
        self.params = params if params else {'test_size': 0.2, 'random_state': 42}
        self.payload = self.split()
        self.out1 = self.payload['node_data'][0]
        self.out2 = self.payload['node_data'][1]

    def split(self):
        try:
            output = train_test_split(self.data,**self.params)
            payload = {"message": "Data split successful", 
                       "node_data": output,
                       "params": self.params, 
                       "node_name": "TrainTestSplit", 
                       "node_type": "preprocessing", 
                       "node_id": id(self), 
                       }
            return payload
        except Exception as e:
            raise ValueError(f"Error splitting data: {e}")

    def __str__(self):
        return f"data: {self.payload}"

    def __call__(self, *args):
        payload = self.payload.copy()
        for arg in args:
            if arg == '1':
                payload['node_data'] = self.out1
            elif arg == '2':
                payload['node_data'] = self.out2
        return payload


if __name__ == "__main__":
    import numpy as np
    data = [[1,2,3,4,5], [6,7,8,9,10]]
    y = np.array([0, 1, 0, 1, 0])
    # data = {
    #     "data":[[0, 1, 0, 1, 0]]
    # }
    splitter = TrainTestSplit(data)
    print(splitter('1'))
