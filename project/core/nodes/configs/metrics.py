from sklearn.metrics import (
    accuracy_score, precision_score, 
    recall_score, f1_score, mean_squared_error, 
    mean_absolute_error, r2_score
    )

METRICS = {
    "accuracy" : accuracy_score,
    "precision" : precision_score,
    "recall" : recall_score,
    "f1" : f1_score,
    "mse" : mean_squared_error,
    "mae" : mean_absolute_error,
    "r2" : r2_score
}