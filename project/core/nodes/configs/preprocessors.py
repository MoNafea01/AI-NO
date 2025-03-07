from sklearn.preprocessing import (
    StandardScaler, 
    MinMaxScaler, 
    MaxAbsScaler, 
    RobustScaler, 
    Normalizer,
    )

from sklearn.preprocessing import (
    LabelBinarizer,
    OrdinalEncoder, 
    OneHotEncoder, 
    LabelEncoder, 
    )

from sklearn.impute import (
    SimpleImputer, 
    KNNImputer
    )

from sklearn.preprocessing import Binarizer

PREPROCESSORS = {
    'scaler':{
        'maxabs_scaler':{'node': MaxAbsScaler, 'params': {}},
        'normalizer':{'node': Normalizer, 'params': {'norm': 'l2'}},
        'minmax_scaler':{'node': MinMaxScaler, 'params': {'feature_range': (0, 1)}},
        'robust_scaler':{'node': RobustScaler, 'params': {'quantile_range': (25.0, 75.0)}},
        'standard_scaler':{'node': StandardScaler, 'params': {'with_mean': True, 'with_std': True}},
    },
    'encoder':{
        'label_encoder':{'node': LabelEncoder, 'params':{}},
        'onehot_encoder':{'node': OneHotEncoder, 'params':{}},
        'ordinal_encoder':{'node': OrdinalEncoder, 'params':{}},
        'label_binarizer':{'node': LabelBinarizer, 'params':{}},
    },
    'imputer':{
        'knn_imputer':{'node': KNNImputer, 'params':{}},
        'simple_imputer':{'node': SimpleImputer, 'params':{}},
    },
    'binarizer':{
        'binarizer':{'node': Binarizer, 'params':{}},
    }
}