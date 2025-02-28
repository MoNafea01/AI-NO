from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework import status
from .models import Node, Component
from .serializers import ModelSerializer

class NodeModelTestCase(TestCase):
    def setUp(self):
        self.node = Node.objects.create(
            node_id=1,
            node_name="linear_regression",
            node_data=b"sample_data",
            params={},
            task="regression",
            node_type="linear_models"
        )
    
    def test_node_creation(self):
        self.assertEqual(self.node.node_name, "linear_regression")
        self.assertEqual(self.node.task, "regression")
        self.assertEqual(self.node.node_type, "linear_models")


class ComponentModelTestCase(TestCase):
    def setUp(self):
        self.component = Component.objects.create(
            displayed_name="Linear Regression",
            idx=2,
            category="Models",
            node_name="linear_regression",
            node_type="linear_models",
            task="regression",
            params={},
            input_channels=None,
            output_channels=["model"],
            api_call="create_model/"
        )
    
    def test_component_creation(self):
        self.assertEqual(self.component.node_name, "linear_regression")
        self.assertEqual(self.component.category, "Models")
        self.assertEqual(self.component.api_call, "create_model/")
        self.assertEqual(self.component.output_channels, ["model"])
        self.assertEqual(self.component.input_channels, None)


class ModelSerializerTestCase(TestCase):
    def test_valid_serializer(self):
        data = {
            "model_name": "dtc",
            "model_type": "tree",
            "task": "classification",
            "params": {"max_depth": 3},
        }
        serializer = ModelSerializer(data=data)
        self.assertTrue(serializer.is_valid())
    
    def test_invalid_serializer(self):
        data = {"task": "classification"}  # Missing required fields
        serializer = ModelSerializer(data=data)
        self.assertFalse(serializer.is_valid())


class ModelAPITestCase(APITestCase):
    def test_create_model(self):
        url = "/api/create_model/"
        data = {
            "model_name": "rbf_svr",
            "model_type": "svm",
            "task": "regression",
            "params": {"C": 1.0}
        }
        response = self.client.post(url, data, format='json')
        n_id = response.json().get('node_id')
        url = f"/api/create_model/?node_id={n_id}"
        self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
    
    def test_create_model_invalid(self):
        url = "/api/create_model/"
        data = {"task": "classification"}  # Missing required fields
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
