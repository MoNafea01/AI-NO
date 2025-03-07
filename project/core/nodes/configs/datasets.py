from sklearn.datasets import (
    make_classification,
    make_regression, 
    load_diabetes, 
    load_digits, 
    load_iris, 
    )


DATASETS = {
    "iris" : load_iris,
    "digits" : load_digits,
    "diabetes" : load_diabetes,
    "make_regression" : make_regression,
    "make_classification" : make_classification
}