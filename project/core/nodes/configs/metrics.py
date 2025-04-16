from sklearn.metrics import (
    mean_absolute_error, 
    mean_squared_error, 
    precision_score, 
    accuracy_score,
    recall_score, 
    f1_score, 
    r2_score,
    log_loss,
    root_mean_squared_error,
    )


METRICS = {
    "f1" : f1_score,
    "r2" : r2_score,
    "recall" : recall_score,
    "mse" : mean_squared_error,
    "accuracy" : accuracy_score,
    "mae" : mean_absolute_error,
    "precision" : precision_score,
    'log_loss' : log_loss,
    'rmse' : root_mean_squared_error,
}
