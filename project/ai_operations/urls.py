# api/urls.py
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView
from rest_framework.routers import DefaultRouter
from .views import *
router = DefaultRouter()
# router.register(r'components', ComponentAPIViewSet)
component_list = ComponentAPIViewSet.as_view({'get': 'list', 'post': 'create'})
component_detail = ComponentAPIViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'})
node_list = NodeAPIViewSet.as_view({'get': 'list', 'post': 'create'})
node_detail = NodeAPIViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'})

urlpatterns = [
    path('api/', include(router.urls)),
    
    path('create_model/', CreateModelView.as_view(), name='create_model'),
    path('fit_model/', FitModelAPIView.as_view(), name='fit_model'),
    path('predict/', PredictAPIView.as_view(), name='predict_model'),
    path('evaluate/', EvaluatorAPIView.as_view(), name='evaluate'),

    path('create_preprocessor/', PreprocessorAPIView.as_view(), name='create_preprocessor'),
    path('fit_preprocessor/', FitPreprocessorAPIView.as_view(), name='fit_preprocessor'),
    path('transform/', TransformAPIView.as_view(), name='transform'),
    path('fit_transform/', FitTransformAPIView.as_view(), name='fit_transform'),

    path('data_loader/', DataLoaderAPIView.as_view(), name='data_loader'),
    path('train_test_split/', TrainTestSplitAPIView.as_view(), name='train_test_split'),
    path('splitter/', SplitterAPIView.as_view(), name='splitter'),
    path('joiner/', JoinerAPIView.as_view(), name='joiner'),

    path('save_node/', NodeSaveAPIView.as_view(), name='save_node'),
    path('load_node/', NodeLoaderAPIView.as_view(), name='load_node'),
    path('clear_nodes/', ClearNodesAPIView.as_view(), name='clear_nodes'),
    path('clear_components/', ClearComponentsAPIView.as_view(), name='clear_components'),

    path('create_input/', InputAPIView.as_view(), name='create_input'),
    path('dense/', DenseAPIView.as_view(), name='dense'),
    path('flatten/', FlattenAPIView.as_view(), name='flatten'),
    path('conv2d/', Conv2DAPIView.as_view(), name='conv2d'),
    path('maxpool2d/', MaxPool2DAPIView.as_view(), name='maxpool2d'),
    path('dropout/', DropoutAPIView.as_view(), name='dropout'),
    path('sequential/', SequentialAPIView.as_view(), name='sequential'),
    

    path('upload_excel/', ExcelUploadAPIView.as_view(), name='upload-excel'),
    path('components/', component_list, name='component-list'),
    path('components/<int:pk>/', component_detail, name='component-detail'),
    path('nodes/', node_list, name='node-list'),
    path('nodes/<int:pk>/', node_detail, name='node-detail'),

    # Generates the raw OpenAPI schema
    path('schema/', SpectacularAPIView.as_view(), name='schema'),
    path('docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    # Redoc UI (alternative)
    path('redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

]
