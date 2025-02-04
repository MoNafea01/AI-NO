# Core workflow execution logic
# core/workflow_executor.py
from project.core.nodes.other.dataLoader import DataLoader

from backend.core.nodes.preprocessing.preprocessor import Scaler
from preprocessing.transform import Transform
from backend.core.nodes.preprocessing.train_test_split import TrainTestSplit
from preprocessing.fit_transform import FitTransform

from model.model import Model
from model.fit import Fit
from model.predict import Predict
from project.core.nodes.other.metrics import Evaluator

class WorkflowExecutor:
    def __init__(self, workflow):
        self.workflow = workflow


    def execute(self):
        # Load data
        load_params = workflow['data_params']
        loader = DataLoader(**load_params)
        X, y = loader.load()

        # Preprocess data
        splitter_params = workflow['splitter_params']
        (X_train, y_train), (X_test, y_test) = TrainTestSplit(X,y,**splitter_params).payload.values()
        trans_params = workflow['transformer_params']
        scaler = Scaler(**trans_params)
        X_train = FitTransform(X_train, scaler).payload['transformed_data']
        X_test = Transform(X_test, scaler).payload['transformed_data']


        # Train model
        model_params = workflow['model_params']
        model = Model(**model_params)
        Fit(X_train, y_train, model)


        # Evaluate model
        metric = workflow['metric']
        evaluator = Evaluator(metric=metric)
        y_pred = Predict(X_test, model).payload['predictions']
        score = evaluator.evaluate(y_test, y_pred)


        return score

if __name__ == "__main__":
    workflow = {
        'data_params': {
            'data_type': 'iris',
            'filepath': r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\backend\core\data.csv"
        },
        'transformer_params':{
            'scaler_name': 'standard',
            'params':{}
        },
        'splitter_params': {
            'test_size': 0.986,
            'random_state': 42
        },
        'model_params': {
            'model_name': 'logistic_regression',
            'model_type': 'linear_models',
            'task': 'classification',
            'params': {'C': 1.0, 'max_iter': 100}
        },
        'metric': 'accuracy'
    }

    executor = WorkflowExecutor(workflow)
    score = executor.execute()
    print(f"Score: {score*100:.2f}%")