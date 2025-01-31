# api/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *
router = DefaultRouter()
router.register(r'components', ComponentAPIViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
    path('create_model/', CreateModelView.as_view(), name='create_model'),
    path('fit_model/', FitModelAPIView.as_view(), name='fit_model'),
    path('predict/', PredictAPIView.as_view(), name='predict_model'),
    path('create_preprocessor/', PreprocessorAPIView.as_view(), name='create_preprocessor'),
    path('fit_preprocessor/', FitPreprocessorAPIView.as_view(), name='fit_preprocessor'),
    path('transform/', TransformAPIView.as_view(), name='transform'),
    path('fit_transform/', FitTransformAPIView.as_view(), name='fit_transform'),
    path('train_test_split/', TrainTestSplitAPIView.as_view(), name='train_test_split'),
    path('splitter/', SplitterAPIView.as_view(), name='splitter'),
    path('joiner/', JoinerAPIView.as_view(), name='joiner'),
    path('data_loader/', DataLoaderAPIView.as_view(), name='data_loader'),
    path('upload_excel/', ExcelUploadAPIView.as_view(), name='upload-excel'),
    path('save_node/', NodeSaveAPIView.as_view(), name='save_node'),
    path('load_node/', NodeLoaderAPIView.as_view(), name='load_node'),
]
