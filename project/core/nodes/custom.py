from .utils import NodeSaver, DataHandler, PayloadBuilder

class Joiner:
    """
    This Class is responsible for joining two datasets.\n
    to get the joined data, call the instance with 'out' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """
    def __init__(self, X, y):
        self.X = DataHandler.extract_data(X)
        self.y = DataHandler.extract_data(y)
        self.payload = self.join()
    
    def join(self):
        try:
            joined_data = (self.X, self.y)
            payload = PayloadBuilder.build_payload("joined_data", joined_data, "joiner", node_type="join")
            NodeSaver()(payload, "core/nodes/saved/data")
            return payload
        except Exception as e:
            raise ValueError(f"Error joining data: {e}")
    
    def __str__(self):
        return f"data: {self.payload}"
    
    def __call__(self, *args):
        return self.payload