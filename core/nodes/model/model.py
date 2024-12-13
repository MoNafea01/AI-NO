# Model training nodes
# core/nodes/models.py
from models import MODELS as models
from utils import save_model
# ai_operations/utils/model/model.py

class Model:
    def __init__(self, model_name, model_type, task, params):
        self.model_name = model_name
        self.model_type = model_type
        self.task = task
        self.params = params
        self.payload = {"message": f"Model hadn't been created yet", "params": None, "model": None, 
                        "model_name": None, "model_type": None, "task": None, "model_id": None}
        self.model = self.create_model()
        
    # return payload

    def create_model(self):
        if self.model_type not in models:
            raise ValueError(f"Unsupported model type: {self.model_type}")
        
        if self.task not in models[self.model_type]:
            raise ValueError(f"Unsupported task type: {self.task}")
        
        if self.model_name not in models[self.model_type][self.task]:
            raise ValueError(f"Unsupported model type: {self.model_name}")
        
        model = models[self.model_type][self.task][self.model_name]['model'](**self.params)
        self.payload = {"message": f"Model created {self.model_name}", "params": self.params, 
            "model": model, "model_name": self.model_name, "model_type": self.model_type, 
            "task": self.task,"model_id": id(model)}
        save_model(self.payload)
        return self.payload

    def __str__(self):
        return f'{self.payload}'



if __name__ == '__main__':
    model = Model('linear_regression', 'linear_models', 'regression', {})
    print(model)