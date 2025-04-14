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
                'bagging_regressor':{'node': BaggingRegressor,'params': {}},
                'adaboost_regressor':{'node': AdaBoostRegressor,'params': {}},
                'gradient_boosting_regressor':{'node': GradientBoostingRegressor,'params': {}},
                'decision_tree_regressor':{'node': DecisionTreeRegressor,'params': {'max_depth': None,}},
                'random_forest_regressor':{'node': RandomForestRegressor,'params': {'n_estimators': 100,'max_depth': None,}},
            },
        'classification':{
                'bagging_classifier':{'node': BaggingClassifier,'params': {}},
                'adaboost_classifier':{'node': AdaBoostClassifier,'params': {}},
                'gradient_boosting_classifier':{'node': GradientBoostingClassifier,'params': {}},
                'decision_tree_classifier':{'node': DecisionTreeClassifier,'params': {'max_depth': None,}},
                'random_forest_classifier':{'node': RandomForestClassifier,'params': {'n_estimators': 100,'max_depth': None,}},
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
            'knn_regressor':{'node': KNeighborsRegressor,'params': {'n_neighbors': 5,}},
            },
        'classification':{
            'knn_classifier':{'node': KNeighborsClassifier,'params': {'n_neighbors': 5,}},
            }
    },
}
