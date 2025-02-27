from sklearn.preprocessing import StandardScaler, MinMaxScaler, MaxAbsScaler, RobustScaler, Normalizer
from sklearn.preprocessing import LabelEncoder, OneHotEncoder, OrdinalEncoder, LabelBinarizer
from sklearn.impute import SimpleImputer, KNNImputer
from sklearn.preprocessing import Binarizer

PREPROCESSORS = {
    'scaler':{
        'standard_scaler':{'node': StandardScaler, 'params': {'with_mean': True, 'with_std': True}},
        'minmax_scaler':{'node': MinMaxScaler, 'params': {'feature_range': (0, 1)}},
        'maxabs_scaler':{'node': MaxAbsScaler, 'params': {}},
        'robust_scaler':{'node': RobustScaler, 'params': {'quantile_range': (25.0, 75.0)}},
        'normalizer':{'node': Normalizer, 'params': {'norm': 'l2'}},
    },
    'encoder':{
        'label_encoder':{'node': LabelEncoder, 'params':{}},
        'onehot_encoder':{'node': OneHotEncoder, 'params':{}},
        'ordinal_encoder':{'node': OrdinalEncoder, 'params':{}},
        'label_binarizer':{'node': LabelBinarizer, 'params':{}},
    },
    'imputer':{
        'simple_imputer':{'node': SimpleImputer, 'params':{}},
        'knn_imputer':{'node': KNNImputer, 'params':{}},
    },
    'binarizer':{
        'binarizer':{'node': Binarizer, 'params':{}},
    }
}