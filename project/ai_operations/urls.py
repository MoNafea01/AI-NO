# api/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *
router = DefaultRouter()
router.register(r'workflows', WorkflowViewSet)

urlpatterns = [
    path('ai_operations/', include(router.urls)),
    path('create_model/', CreateModelView.as_view(), name='create_model'),
    path('fit_model/', FitModelAPIView.as_view(), name='fit_model'),
    path('predict/', PredictAPIView.as_view(), name='predict_model'),
    path('create_preprocessor/', PreprocessorAPIView.as_view(), name='create_preprocessor'),
    path('fit_preprocessor/', FitPreprocessorAPIView.as_view(), name='fit_preprocessor'),
    path('transform/', TransformAPIView.as_view(), name='transform'),
    path('fit_transform/', FitTransformAPIView.as_view(), name='fit_transform'),
    path('train_test_split/', TrainTestSplitAPIView.as_view(), name='train_test_split'),
    path('splitter/', SplitterAPIView.as_view(), name='splitter'),
    path('data_loader/', DataLoaderAPIView.as_view(), name='data_loader'),
]
