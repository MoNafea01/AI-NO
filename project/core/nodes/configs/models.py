from sklearn.linear_model import (
    LogisticRegression, 
    LinearRegression, 
    RidgeClassifier, 
    SGDClassifier, 
    SGDRegressor,
    ElasticNet, 
    Lasso, 
    Ridge, 
    )

from sklearn.ensemble import (
    GradientBoostingRegressor, 
    RandomForestClassifier, 
    RandomForestRegressor, 
    AdaBoostRegressor, 
    BaggingRegressor,
    )

from sklearn.svm import (
    LinearSVC, 
    LinearSVR, 
    SVC, 
    SVR,
    )

from sklearn.tree import (
    DecisionTreeClassifier, 
    DecisionTreeRegressor,
    )



from sklearn.ensemble import (
    GradientBoostingClassifier, 
    AdaBoostClassifier, 
    BaggingClassifier,
    )

from sklearn.naive_bayes import (
    MultinomialNB, 
    BernoulliNB,
    GaussianNB, 
    )

from sklearn.neighbors import (
    KNeighborsClassifier,
    KNeighborsRegressor, 
    )


MODELS = {
    'linear_models':{
        'regression':{
                'ridge':{'node': Ridge,'params': {'alpha': 1.0,}},
                'lasso':{'node': Lasso,'params': {'alpha': 1.0,}},
                'linear_regression':{'node': LinearRegression,'params': {}},
                'sgd_regression':{'node': SGDRegressor,'params': {'penalty': 'l2',}},
                'elastic_net':{'node': ElasticNet,'params': {'alpha': 1.0, 'l1_ratio': 0.5,}},
            },
        'classification':{
                'sgd_classifier':{'node': SGDClassifier,'params': {'penalty': 'l2',}},
                'ridge_classifier':{'node': RidgeClassifier,'params': {'alpha': 1.0,}},
                'logistic_regression':{'node': LogisticRegression,'params': {'penalty': 'l2','C': 1.0,}},
            }
    },
    'svm':{
        'regression':{
                'rbf_svr':{'node': SVR,'params': {'C': 1.0}},
                'linear_svr':{'node': LinearSVR,'params': {'C': 1.0,}},
                'poly_svr':{'node': SVR,'params': {'C': 1.0, 'kernel': 'poly',}},
                'sigmoid_svr':{'node': SVR,'params': {'C': 1.0, 'kernel': 'sigmoid',}},
            },
        'classification':{
                'rbf_svc':{'node': SVC,'params': {'C': 1.0}},
                'linear_svc':{'node': LinearSVC,'params': {'C': 1.0,}},
                'poly_svc':{'node': SVC,'params': {'C': 1.0, 'kernel': 'poly',}},
                'sigmoid_svc':{'node': SVC,'params': {'C': 1.0, 'kernel': 'sigmoid',}},
            }
    },
    'tree':{
        'regression':{
                'br':{'node': BaggingRegressor,'params': {}},
                'adr':{'node': AdaBoostRegressor,'params': {}},
                'gbr':{'node': GradientBoostingRegressor,'params': {}},
                'dtr':{'node': DecisionTreeRegressor,'params': {'max_depth': None,}},
                'rfr':{'node': RandomForestRegressor,'params': {'n_estimators': 100,'max_depth': None,}},
            },
        'classification':{
                'bc':{'node': BaggingClassifier,'params': {}},
                'adc':{'node': AdaBoostClassifier,'params': {}},
                'gbc':{'node': GradientBoostingClassifier,'params': {}},
                'dtc':{'node': DecisionTreeClassifier,'params': {'max_depth': None,}},
                'rfc':{'node': RandomForestClassifier,'params': {'n_estimators': 100,'max_depth': None,}},
            },
    },
    'naive_bayes':{
        'regression':{
        },
        'classification':{
                'gaussian_nb':{'node': GaussianNB,'params': {}},
                'bernoulli_nb':{'node': BernoulliNB,'params': {}},
                'multinomial_nb':{'node': MultinomialNB,'params': {}},
            }
    },
    'knn':{
        'regression':{
            'knnr':{'node': KNeighborsRegressor,'params': {'n_neighbors': 5,}},
            },
        'classification':{
            'knnc':{'node': KNeighborsClassifier,'params': {'n_neighbors': 5,}},
            }
    },
}
