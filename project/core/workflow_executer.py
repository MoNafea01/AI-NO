# Core workflow execution logic
# core/workflow_executor.py
from core.nodes.other.dataLoader import DataLoader
from core.nodes.preprocessing.preprocessor import Preprocessor
from core.nodes.model.model import Model
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
        preprocess_params = workflow['preprocess_params']
        preprocessor = Preprocessor(**preprocess_params)
        X_train, X_test, y_train, y_test = preprocessor.preprocess(X, y)

        # Train model
        model_params = workflow['model_params']
        model_trainer = Model(**model_params)
        model = model_trainer.train(X_train, y_train)

        # Evaluate model
        metric = workflow['metric']
        evaluator = Evaluator(metric=metric)
        y_pred = model.predict(X_test)
        score = evaluator.evaluate(y_test, y_pred)

        return score

if __name__ == "__main__":
    # Example workflow
    workflow = {
        'data_params': {
            'data_type': 'custom',
            'filepath': 'backend/core/data.csv'
        },
        'preprocess_params': {
            'scaling': True,
            'test_size': 0.2,
            'random_state': 42,
            'scaler_type': None,
            'split_data': True
        },
        'model_params': {
            'model_type': 'logistic_regression'
        },
        'metric': 'accuracy'
    }

    executor = WorkflowExecutor(workflow)
    score = executor.execute()
    print(f"Score: {score}")