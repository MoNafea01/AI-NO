from sklearn.datasets import (
    load_iris, load_diabetes, 
    load_digits, make_regression, 
    make_classification
    )


DATASETS = {
    "iris" : load_iris,
    "diabetes" : load_diabetes,
    "digits" : load_digits,
    "make_regression" : make_regression,
    "make_classification" : make_classification
}