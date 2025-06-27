from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
import joblib
import warnings

warnings.filterwarnings("ignore", category=UserWarning, module="sklearn")


class PipelineIntegrationTest(APITestCase):
    @classmethod
    def setUp(self):
        super().setUpClass()

    def test_07_logistic_regression_pipeline_with_iris(self):
        # Step 1: Load Iris Data
        url = reverse('data_loader')  # make sure to define your URL names accordingly

        data = {"params": {"dataset_name": "iris"}}
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        response = self.client.put(url, {"params":{"dataset_name":"iris"}}, format='json', query_params={"node_id":response.data.get('node_id'), "project_id": 1})
        print("daaaata",response.data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data_loader_X, data_loader_y = response.data.get('children')
        self.assertIsNotNone(data_loader_X)
        self.assertIsNotNone(data_loader_y)

        # Step 2: Split the Data
        url = reverse('train_test_split')
        data = {
            "X": data_loader_X,
            "y": data_loader_y,
            "params":{"test_size": 0.3, "random_state": 42}
        }
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        X, y = response.data.get('children')
        self.assertIsNotNone(X)
        self.assertIsNotNone(y)
        

        data = self.client.get(reverse('train_test_split'), format="json", query_params={"node_id":response.data.get("node_id"), "return_data": 1, "project_id": 1})
        (X_train, X_test),(y_train, y_test) = data.data.get("node_data")

        # Step 3: Create Scaler Preprocessor
        url = reverse('create_preprocessor')
        data = {
            "preprocessor_name": "standard_scaler",
            "preprocessor_type": "scaler"
        }
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        preprocessor_id = response.data.get('node_id')
        self.assertIsNotNone(preprocessor_id)

        # Step 4: Fit the Preprocessor
        url = reverse('fit_transform')
        data = {
            "data": X_train,
            "preprocessor": preprocessor_id
        }
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        fitted_preprocessor_id, X_train = response.data.get('children')
        self.assertIsNotNone(fitted_preprocessor_id)
        self.assertIsNotNone(X_train)
        
        url = reverse('transform')
        data = {
            "data": X_test,
            "fitted_preprocessor": fitted_preprocessor_id
        }
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        X_test = response.data.get('node_id')
        self.assertIsNotNone(X_test)

        # Step 6: Create Logistic Regression Model
        url = reverse('create_model')
        data = {
            "model_name": "logistic_regression",
            "model_type": "linear_models",
            "task": "classification"
        }
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        model_id = response.data.get('node_id')
        self.assertIsNotNone(model_id)


        # Step 7: Fit the Model
        url = reverse('fit_model')
        data = {
            "X": X_train,
            "y": y_train,
            "model": model_id
        }
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        fitted_model_id = response.data.get('node_id')
        self.assertIsNotNone(fitted_model_id)

        # Step 8: Generate Predictions
        url = reverse('predict_model')
        data = {
            "X": X_test,
            "fitted_model": fitted_model_id
        }
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        predictions_id = response.data.get('node_id')
        self.assertIsNotNone(predictions_id)

        # Step 9: Evaluate the Results
        url = reverse('evaluate')
        data = {
            "params": {"metric": "accuracy"},
            "y_true": y_test,
            "y_pred": predictions_id
        }
        response = self.client.post(url, data, format='json', query_params={"project_id": 1})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        response = self.client.get(url, query_params={"node_id":response.data.get('node_id'), 'return_data':1, "project_id": 1})
        score = response.data.get('node_data')
        self.assertIsNotNone(score)

        print(f"\nSCORE: {score*100} %") 

        self.client.delete(reverse('clear_nodes'), query_params={"test":1, "project_id": 1})


class PreprocessorTest(APITestCase):
    """Dedicated test class for comprehensive preprocessor testing"""
    
    def setUp(self):
        """Set up test data for preprocessor tests"""
        # Create sample data
        self.data_response = self.client.post("/api/data_loader/", 
                                            {"params": {"dataset_name": "diabetes"}}, 
                                            format="json")
        self.data_node_id = self.data_response.data.get("node_id")
        
        # Get the actual data
        data_get_response = self.client.get("/api/data_loader/", format="json", 
                                          query_params={"node_id": self.data_node_id, "return_data": 1})
        self.X, self.y = data_get_response.data.get("children")
        
        # Split data for testing
        split_response = self.client.post("/api/train_test_split/", 
                                        {"X": self.X, "y": self.y, 
                                         "params": {"test_size": 0.2, "random_state": 42}}, 
                                        format="json")
        self.split_node_id = split_response.data.get("node_id")
        
        # Get split data
        split_data_response = self.client.get("/api/train_test_split/", format="json",
                                            query_params={"node_id": self.split_node_id, "return_data": 1})
        (self.X_train, self.X_test), (self.y_train, self.y_test) = split_data_response.data.get("node_data")

    def tearDown(self):
        """Clean up after tests"""
        # Clean up created nodes
        if hasattr(self, 'data_node_id'):
            self.client.delete("/api/data_loader/", format="json", 
                              query_params={"node_id": self.data_node_id})
        if hasattr(self, 'split_node_id'):
            self.client.delete("/api/train_test_split/", format="json", 
                              query_params={"node_id": self.split_node_id})

    def test_standard_scaler_creation(self):
        """Test creation of StandardScaler preprocessor"""
        url = '/api/create_preprocessor/'
        data = {
            "preprocessor_name": "standard_scaler",
            "preprocessor_type": "scaler"
        }
        response = self.client.post(url, data, format="json")
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data.get("node_name"), "standard_scaler")
        self.assertIsNotNone(response.data.get("node_id"))
        
        # Clean up
        node_id = response.data.get("node_id")
        self.client.delete(url, format="json", query_params={"node_id": node_id})

    def test_minmax_scaler_creation(self):
        """Test creation of MinMaxScaler preprocessor"""
        url = '/api/create_preprocessor/'
        data = {
            "preprocessor_name": "minmax_scaler",
            "preprocessor_type": "scaler"
        }
        response = self.client.post(url, data, format="json")
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data.get("node_name"), "minmax_scaler")
        self.assertIsNotNone(response.data.get("node_id"))
        
        # Clean up
        node_id = response.data.get("node_id")
        self.client.delete(url, format="json", query_params={"node_id": node_id})

    def test_fit_preprocessor_functionality(self):
        """Test fitting a preprocessor with training data"""
        # Create preprocessor
        create_url = '/api/create_preprocessor/'
        create_data = {
            "preprocessor_name": "standard_scaler",
            "preprocessor_type": "scaler"
        }
        create_response = self.client.post(create_url, create_data, format="json")
        preprocessor_id = create_response.data.get("node_id")
        
        # Fit preprocessor
        fit_url = '/api/fit_preprocessor/'
        fit_data = {
            "data": self.X_train,
            "preprocessor": preprocessor_id
        }
        fit_response = self.client.post(fit_url, fit_data, format="json")
        
        self.assertEqual(fit_response.status_code, status.HTTP_201_CREATED)
        self.assertIsNotNone(fit_response.data.get("node_id"))
        
        # Clean up
        fitted_id = fit_response.data.get("node_id")
        self.client.delete(create_url, format="json", query_params={"node_id": preprocessor_id})
        self.client.delete(fit_url, format="json", query_params={"node_id": fitted_id})

    def test_transform_functionality(self):
        """Test transforming data with a fitted preprocessor"""
        # Create and fit preprocessor
        create_url = '/api/create_preprocessor/'
        create_data = {
            "preprocessor_name": "standard_scaler",
            "preprocessor_type": "scaler"
        }
        create_response = self.client.post(create_url, create_data, format="json")
        preprocessor_id = create_response.data.get("node_id")
        
        fit_url = '/api/fit_preprocessor/'
        fit_data = {
            "data": self.X_train,
            "preprocessor": preprocessor_id
        }
        fit_response = self.client.post(fit_url, fit_data, format="json")
        fitted_preprocessor_id = fit_response.data.get("node_id")
        
        # Transform test data
        transform_url = '/api/transform/'
        transform_data = {
            "data": self.X_test,
            "fitted_preprocessor": fitted_preprocessor_id
        }
        transform_response = self.client.post(transform_url, transform_data, format="json")
        
        self.assertEqual(transform_response.status_code, status.HTTP_201_CREATED)
        self.assertIsNotNone(transform_response.data.get("node_id"))
        
        # Clean up
        transform_id = transform_response.data.get("node_id")
        self.client.delete(create_url, format="json", query_params={"node_id": preprocessor_id})
        self.client.delete(fit_url, format="json", query_params={"node_id": fitted_preprocessor_id})
        self.client.delete(transform_url, format="json", query_params={"node_id": transform_id})

    def test_fit_transform_functionality(self):
        """Test combined fit and transform in one step"""
        # Create preprocessor
        create_url = '/api/create_preprocessor/'
        create_data = {
            "preprocessor_name": "standard_scaler",
            "preprocessor_type": "scaler"
        }
        create_response = self.client.post(create_url, create_data, format="json")
        preprocessor_id = create_response.data.get("node_id")
        
        # Fit and transform in one step
        fit_transform_url = '/api/fit_transform/'
        fit_transform_data = {
            "data": self.X_train,
            "preprocessor": preprocessor_id
        }
        fit_transform_response = self.client.post(fit_transform_url, fit_transform_data, format="json")
        
        self.assertEqual(fit_transform_response.status_code, status.HTTP_201_CREATED)
        # Should return both fitted preprocessor and transformed data
        children = fit_transform_response.data.get("children")
        self.assertIsNotNone(children)
        self.assertEqual(len(children), 2)  # fitted_preprocessor_id and transformed_data_id
        
        # Clean up
        fit_transform_id = fit_transform_response.data.get("node_id")
        self.client.delete(create_url, format="json", query_params={"node_id": preprocessor_id})
        self.client.delete(fit_transform_url, format="json", query_params={"node_id": fit_transform_id})

    def test_preprocessor_validation_errors(self):
        """Test validation errors for preprocessor endpoints"""
        # Test create_preprocessor without required fields
        create_url = '/api/create_preprocessor/'
        invalid_data = {}
        response = self.client.post(create_url, invalid_data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        
        # Test fit_preprocessor without data
        fit_url = '/api/fit_preprocessor/'
        invalid_fit_data = {"preprocessor": 123}
        response = self.client.post(fit_url, invalid_fit_data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        
        # Test transform without fitted_preprocessor
        transform_url = '/api/transform/'
        invalid_transform_data = {"data": self.X_test}
        response = self.client.post(transform_url, invalid_transform_data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_preprocessor_types(self):
        """Test different preprocessor types"""
        create_url = '/api/create_preprocessor/'
        
        # Test different preprocessor types
        preprocessor_types = [
            {"preprocessor_name": "standard_scaler", "preprocessor_type": "scaler"},
            {"preprocessor_name": "minmax_scaler", "preprocessor_type": "scaler"},
            {"preprocessor_name": "robust_scaler", "preprocessor_type": "scaler"},
        ]
        
        created_ids = []
        
        for preprocessor_data in preprocessor_types:
            response = self.client.post(create_url, preprocessor_data, format="json")
            if response.status_code == status.HTTP_201_CREATED:
                created_ids.append(response.data.get("node_id"))
                self.assertEqual(response.data.get("node_name"), preprocessor_data["preprocessor_name"])
        
        # Clean up
        for node_id in created_ids:
            self.client.delete(create_url, format="json", query_params={"node_id": node_id})


class ModelTest(APITestCase):
    """Dedicated test class for comprehensive model testing"""
    
    def setUp(self):
        """Set up test data for model tests"""
        # Create sample data
        self.data_response = self.client.post("/api/data_loader/", 
                                            {"params": {"dataset_name": "iris"}}, 
                                            format="json")
        self.data_node_id = self.data_response.data.get("node_id")
        
        # Get the actual data
        data_get_response = self.client.get("/api/data_loader/", format="json", 
                                          query_params={"node_id": self.data_node_id, "return_data": 1})
        self.X, self.y = data_get_response.data.get("children")
        
        # Split data for testing
        split_response = self.client.post("/api/train_test_split/", 
                                        {"X": self.X, "y": self.y, 
                                         "params": {"test_size": 0.2, "random_state": 42}}, 
                                        format="json")
        self.split_node_id = split_response.data.get("node_id")
        
        # Get split data
        split_data_response = self.client.get("/api/train_test_split/", format="json",
                                            query_params={"node_id": self.split_node_id, "return_data": 1})
        (self.X_train, self.X_test), (self.y_train, self.y_test) = split_data_response.data.get("node_data")

    def tearDown(self):
        """Clean up after tests"""
        # Clean up created nodes
        if hasattr(self, 'data_node_id'):
            self.client.delete("/api/data_loader/", format="json", 
                              query_params={"node_id": self.data_node_id})
        if hasattr(self, 'split_node_id'):
            self.client.delete("/api/train_test_split/", format="json", 
                              query_params={"node_id": self.split_node_id})

    def test_logistic_regression_creation(self):
        """Test creation of Logistic Regression model"""
        url = '/api/create_model/'
        data = {
            "model_name": "logistic_regression",
            "model_type": "linear_models",
            "task": "classification"
        }
        response = self.client.post(url, data, format="json")
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data.get("node_name"), "logistic_regression")
        self.assertIsNotNone(response.data.get("node_id"))
        
        # Clean up
        node_id = response.data.get("node_id")
        self.client.delete(url, format="json", query_params={"node_id": node_id})

    def test_linear_regression_creation(self):
        """Test creation of Linear Regression model"""
        url = '/api/create_model/'
        data = {
            "model_name": "linear_regression",
            "model_type": "linear_models",
            "task": "regression"
        }
        response = self.client.post(url, data, format="json")
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data.get("node_name"), "linear_regression")
        self.assertIsNotNone(response.data.get("node_id"))
        
        # Clean up
        node_id = response.data.get("node_id")
        self.client.delete(url, format="json", query_params={"node_id": node_id})

    def test_model_fitting_functionality(self):
        """Test fitting a model with training data"""
        # Create model
        create_url = '/api/create_model/'
        create_data = {
            "model_name": "logistic_regression",
            "model_type": "linear_models",
            "task": "classification"
        }
        create_response = self.client.post(create_url, create_data, format="json")
        model_id = create_response.data.get("node_id")
        
        # Fit model
        fit_url = '/api/fit_model/'
        fit_data = {
            "X": self.X_train,
            "y": self.y_train,
            "model": model_id
        }
        fit_response = self.client.post(fit_url, fit_data, format="json")
        
        self.assertEqual(fit_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(fit_response.data.get("node_name"), "model_fitter")
        self.assertIsNotNone(fit_response.data.get("node_id"))
        
        # Clean up
        fitted_id = fit_response.data.get("node_id")
        self.client.delete(create_url, format="json", query_params={"node_id": model_id})
        self.client.delete(fit_url, format="json", query_params={"node_id": fitted_id})

    def test_model_prediction_functionality(self):
        """Test making predictions with a fitted model"""
        # Create and fit model
        create_url = '/api/create_model/'
        create_data = {
            "model_name": "logistic_regression",
            "model_type": "linear_models",
            "task": "classification"
        }
        create_response = self.client.post(create_url, create_data, format="json")
        model_id = create_response.data.get("node_id")
        
        fit_url = '/api/fit_model/'
        fit_data = {
            "X": self.X_train,
            "y": self.y_train,
            "model": model_id
        }
        fit_response = self.client.post(fit_url, fit_data, format="json")
        fitted_model_id = fit_response.data.get("node_id")
        
        # Make predictions
        predict_url = '/api/predict/'
        predict_data = {
            "X": self.X_test,
            "fitted_model": fitted_model_id
        }
        predict_response = self.client.post(predict_url, predict_data, format="json")
        
        self.assertEqual(predict_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(predict_response.data.get("node_name"), "predictor")
        self.assertIsNotNone(predict_response.data.get("node_id"))
        
        # Clean up
        predict_id = predict_response.data.get("node_id")
        self.client.delete(create_url, format="json", query_params={"node_id": model_id})
        self.client.delete(fit_url, format="json", query_params={"node_id": fitted_model_id})
        self.client.delete(predict_url, format="json", query_params={"node_id": predict_id})

    def test_model_evaluation_functionality(self):
        """Test evaluating model predictions"""
        # Create, fit model and make predictions
        create_url = '/api/create_model/'
        create_data = {
            "model_name": "logistic_regression",
            "model_type": "linear_models",
            "task": "classification"
        }
        create_response = self.client.post(create_url, create_data, format="json")
        model_id = create_response.data.get("node_id")
        
        fit_url = '/api/fit_model/'
        fit_data = {
            "X": self.X_train,
            "y": self.y_train,
            "model": model_id
        }
        fit_response = self.client.post(fit_url, fit_data, format="json")
        fitted_model_id = fit_response.data.get("node_id")
        
        predict_url = '/api/predict/'
        predict_data = {
            "X": self.X_test,
            "fitted_model": fitted_model_id
        }
        predict_response = self.client.post(predict_url, predict_data, format="json")
        predictions_id = predict_response.data.get("node_id")
        
        # Evaluate predictions
        evaluate_url = '/api/evaluate/'
        evaluate_data = {
            "params": {"metric": "accuracy"},
            "y_true": self.y_test,
            "y_pred": predictions_id
        }
        evaluate_response = self.client.post(evaluate_url, evaluate_data, format="json")
        
        self.assertEqual(evaluate_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(evaluate_response.data.get("node_name"), "evaluator")
        self.assertIsNotNone(evaluate_response.data.get("node_id"))
        
        # Get evaluation results
        eval_id = evaluate_response.data.get("node_id")
        eval_result = self.client.get(evaluate_url, format="json", 
                                    query_params={"node_id": eval_id, "return_data": 1})
        score = eval_result.data.get("node_data")
        self.assertIsNotNone(score)
        self.assertTrue(0 <= score <= 1)  # Accuracy should be between 0 and 1
        
        # Clean up
        self.client.delete(create_url, format="json", query_params={"node_id": model_id})
        self.client.delete(fit_url, format="json", query_params={"node_id": fitted_model_id})
        self.client.delete(predict_url, format="json", query_params={"node_id": predictions_id})
        self.client.delete(evaluate_url, format="json", query_params={"node_id": eval_id})

    def test_model_validation_errors(self):
        """Test validation errors for model endpoints"""
        # Test create_model without required fields
        create_url = '/api/create_model/'
        invalid_data = {}
        response = self.client.post(create_url, invalid_data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        
        # Test fit_model without data
        fit_url = '/api/fit_model/'
        invalid_fit_data = {"model": 123}
        response = self.client.post(fit_url, invalid_fit_data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        
        # Test predict without fitted_model
        predict_url = '/api/predict/'
        invalid_predict_data = {"X": self.X_test}
        response = self.client.post(predict_url, invalid_predict_data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_model_types(self):
        """Test different model types"""
        create_url = '/api/create_model/'
        
        # Test different model types
        model_types = [
            {"model_name": "logistic_regression", "model_type": "linear_models", "task": "classification"},
            {"model_name": "linear_regression", "model_type": "linear_models", "task": "regression"},
            {"model_name": "random_forest", "model_type": "ensemble", "task": "classification"},
            {"model_name": "svm", "model_type": "svm", "task": "classification"},
        ]
        
        created_ids = []
        
        for model_data in model_types:
            response = self.client.post(create_url, model_data, format="json")
            if response.status_code == status.HTTP_201_CREATED:
                created_ids.append(response.data.get("node_id"))
                self.assertEqual(response.data.get("node_name"), model_data["model_name"])
        
        # Clean up
        for node_id in created_ids:
            self.client.delete(create_url, format="json", query_params={"node_id": node_id})

    def test_complete_model_pipeline(self):
        """Test complete model pipeline from creation to evaluation"""
        # Create model
        create_url = '/api/create_model/'
        create_data = {
            "model_name": "logistic_regression",
            "model_type": "linear_models",
            "task": "classification"
        }
        create_response = self.client.post(create_url, create_data, format="json")
        model_id = create_response.data.get("node_id")
        self.assertIsNotNone(model_id)
        
        # Fit model
        fit_url = '/api/fit_model/'
        fit_data = {
            "X": self.X_train,
            "y": self.y_train,
            "model": model_id
        }
        fit_response = self.client.post(fit_url, fit_data, format="json")
        fitted_model_id = fit_response.data.get("node_id")
        self.assertIsNotNone(fitted_model_id)
        
        # Make predictions
        predict_url = '/api/predict/'
        predict_data = {
            "X": self.X_test,
            "fitted_model": fitted_model_id
        }
        predict_response = self.client.post(predict_url, predict_data, format="json")
        predictions_id = predict_response.data.get("node_id")
        self.assertIsNotNone(predictions_id)
        
        # Evaluate predictions
        evaluate_url = '/api/evaluate/'
        evaluate_data = {
            "params": {"metric": "accuracy"},
            "y_true": self.y_test,
            "y_pred": predictions_id
        }
        evaluate_response = self.client.post(evaluate_url, evaluate_data, format="json")
        eval_id = evaluate_response.data.get("node_id")
        self.assertIsNotNone(eval_id)
        
        # Get evaluation results
        eval_result = self.client.get(evaluate_url, format="json", 
                                    query_params={"node_id": eval_id, "return_data": 1})
        score = eval_result.data.get("node_data")
        self.assertIsNotNone(score)
        
        print(f"\nModel Pipeline Test - Accuracy Score: {score*100:.2f}%")
        
        # Clean up
        self.client.delete(create_url, format="json", query_params={"node_id": model_id})
        self.client.delete(fit_url, format="json", query_params={"node_id": fitted_model_id})
        self.client.delete(predict_url, format="json", query_params={"node_id": predictions_id})
        self.client.delete(evaluate_url, format="json", query_params={"node_id": eval_id})

    def test_regression_model_workflow(self):
        """Test regression model workflow with diabetes dataset"""
        # Load diabetes dataset for regression
        diabetes_data_response = self.client.post("/api/data_loader/", 
                                                {"params": {"dataset_name": "diabetes"}}, 
                                                format="json")
        diabetes_data_node_id = diabetes_data_response.data.get("node_id")
        
        # Get the actual data
        diabetes_get_response = self.client.get("/api/data_loader/", format="json", 
                                              query_params={"node_id": diabetes_data_node_id, "return_data": 1})
        diabetes_X, diabetes_y = diabetes_get_response.data.get("children")
        
        # Split data
        diabetes_split_response = self.client.post("/api/train_test_split/", 
                                                 {"X": diabetes_X, "y": diabetes_y, 
                                                  "params": {"test_size": 0.2, "random_state": 42}}, 
                                                 format="json")
        diabetes_split_node_id = diabetes_split_response.data.get("node_id")
        
        # Get split data
        diabetes_split_data_response = self.client.get("/api/train_test_split/", format="json",
                                                     query_params={"node_id": diabetes_split_node_id, "return_data": 1})
        (diabetes_X_train, diabetes_X_test), (diabetes_y_train, diabetes_y_test) = diabetes_split_data_response.data.get("node_data")
        
        # Create linear regression model
        create_url = '/api/create_model/'
        create_data = {
            "model_name": "linear_regression",
            "model_type": "linear_models",
            "task": "regression"
        }
        create_response = self.client.post(create_url, create_data, format="json")
        model_id = create_response.data.get("node_id")
        
        # Fit model
        fit_url = '/api/fit_model/'
        fit_data = {
            "X": diabetes_X_train,
            "y": diabetes_y_train,
            "model": model_id
        }
        fit_response = self.client.post(fit_url, fit_data, format="json")
        fitted_model_id = fit_response.data.get("node_id")
        
        # Make predictions
        predict_url = '/api/predict/'
        predict_data = {
            "X": diabetes_X_test,
            "fitted_model": fitted_model_id
        }
        predict_response = self.client.post(predict_url, predict_data, format="json")
        predictions_id = predict_response.data.get("node_id")
        
        # Evaluate with R2 score (for regression)
        evaluate_url = '/api/evaluate/'
        evaluate_data = {
            "params": {"metric": "r2"},
            "y_true": diabetes_y_test,
            "y_pred": predictions_id
        }
        evaluate_response = self.client.post(evaluate_url, evaluate_data, format="json")
        eval_id = evaluate_response.data.get("node_id")
        
        # Get evaluation results
        eval_result = self.client.get(evaluate_url, format="json", 
                                    query_params={"node_id": eval_id, "return_data": 1})
        r2_score = eval_result.data.get("node_data")
        self.assertIsNotNone(r2_score)
        
        print(f"\nRegression Model Test - R2 Score: {r2_score:.4f}")
        
        # Clean up
        self.client.delete("/api/data_loader/", format="json", 
                          query_params={"node_id": diabetes_data_node_id})
        self.client.delete("/api/train_test_split/", format="json", 
                          query_params={"node_id": diabetes_split_node_id})
        self.client.delete(create_url, format="json", query_params={"node_id": model_id})
        self.client.delete(fit_url, format="json", query_params={"node_id": fitted_model_id})
        self.client.delete(predict_url, format="json", query_params={"node_id": predictions_id})
        self.client.delete(evaluate_url, format="json", query_params={"node_id": eval_id})


class NeuralNetworkTest(APITestCase):
    """Dedicated test class for comprehensive neural network testing"""
    
    def setUp(self):
        """Set up test data for neural network tests"""
        # Create sample data for classification (iris)
        # garbage_dataset_path = "../testing/light_garbage/"
        self.classification_data_response = self.client.post("/api/data_loader/", 
                                                           {"params": {"dataset_name": 'iris'}}, 
                                                           format="json")
        self.classification_data_node_id = self.classification_data_response.data.get("node_id")
        
        # Get the actual classification data
        classification_get_response = self.client.get("/api/data_loader/", format="json", 
                                                    query_params={"node_id": self.classification_data_node_id, "return_data": 1})
        self.classification_X, self.classification_y = classification_get_response.data.get("children")
        
        # Split classification data
        classification_split_response = self.client.post("/api/train_test_split/", 
                                                       {"X": self.classification_X, "y": self.classification_y, 
                                                        "params": {"test_size": 0.2, "random_state": 42}}, 
                                                       format="json")
        self.classification_split_node_id = classification_split_response.data.get("node_id")
        
        # Get split classification data
        classification_split_data_response = self.client.get("/api/train_test_split/", format="json",
                                                           query_params={"node_id": self.classification_split_node_id, "return_data": 1})
        (self.X_train_cls, self.X_test_cls), (self.y_train_cls, self.y_test_cls) = classification_split_data_response.data.get("node_data")

    def tearDown(self):
        """Clean up after tests"""
        # Clean up created nodes
        if hasattr(self, 'classification_data_node_id'):
            self.client.delete("/api/data_loader/", format="json", 
                              query_params={"node_id": self.classification_data_node_id})
        if hasattr(self, 'classification_split_node_id'):
            self.client.delete("/api/train_test_split/", format="json", 
                              query_params={"node_id": self.classification_split_node_id})

    def _create_simple_neural_network(self):
        """Helper method to create a simple neural network for testing"""
        layers = []
        
        # Create input layer
        input_url = '/api/create_input/'
        input_data = {
            "params": {"shape": [4]},  # 4 features for iris dataset
            "name": "input_layer"
        }
        input_response = self.client.post(input_url, input_data, format="json")
        input_id = input_response.data.get("node_id")
        layers.append(input_id)
        
        # Create hidden dense layer
        dense_url = '/api/dense/'
        dense_data = {
            "params": {"units": 4, "activation": "relu"},
            "prev_node": input_id,
            "name": "hidden_layer"
        }
        dense_response = self.client.post(dense_url, dense_data, format="json")
        dense_id = dense_response.data.get("node_id")
        layers.append(dense_id)
        
        # Create output layer
        output_data = {
            "params": {"units": 5, "activation": "softmax"},  # 3 classes for iris
            "prev_node": dense_id,
            "name": "output_layer"
        }
        output_response = self.client.post(dense_url, output_data, format="json")
        output_id = output_response.data.get("node_id")
        layers.append(output_id)
        
        return layers
    
    def _cleanup_neural_network(self, layers):
        """Helper method to clean up neural network layers"""
        # Clean up layers in reverse order
        for layer_id in reversed(layers):
            # Try different endpoints based on layer type
            endpoints = ['/api/create_input/', '/api/dense/']
            for endpoint in endpoints:
                try:
                    self.client.delete(endpoint, format="json", query_params={"node_id": layer_id})
                    break
                except:
                    continue
    
    def _create_cnn_layers(self):
        """Helper method to create CNN layers for testing"""
        layers = []
        
        # Create input layer for images
        input_url = '/api/create_input/'
        input_data = {
            "params": {"shape": [28, 28, 1]},
            "name": "cnn_input_layer"
        }
        input_response = self.client.post(input_url, input_data, format="json")
        input_id = input_response.data.get("node_id")
        layers.append(input_id)
        
        # Create Conv2D layer
        conv_url = '/api/conv2d/'
        conv_data = {
            "params": {"filters": 32, "kernel_size": [3, 3], "activation": "relu"},
            "prev_node": input_id,
            "name": "conv_layer"
        }
        conv_response = self.client.post(conv_url, conv_data, format="json")
        conv_id = conv_response.data.get("node_id")
        layers.append(conv_id)
        
        # Create MaxPool2D layer
        maxpool_url = '/api/maxpool2d/'
        maxpool_data = {
            "params": {"pool_size": [2, 2]},
            "prev_node": conv_id,
            "name": "maxpool_layer"
        }
        maxpool_response = self.client.post(maxpool_url, maxpool_data, format="json")
        maxpool_id = maxpool_response.data.get("node_id")
        layers.append(maxpool_id)
        
        # Create Flatten layer
        flatten_url = '/api/flatten/'
        flatten_data = {
            "prev_node": maxpool_id,
            "name": "flatten_layer"
        }
        flatten_response = self.client.post(flatten_url, flatten_data, format="json")
        flatten_id = flatten_response.data.get("node_id")
        layers.append(flatten_id)
        
        # Create Dense layer
        dense_url = '/api/dense/'
        dense_data = {
            "params": {"units": 64, "activation": "relu"},
            "prev_node": flatten_id,
            "name": "dense_layer"
        }
        dense_response = self.client.post(dense_url, dense_data, format="json")
        dense_id = dense_response.data.get("node_id")
        layers.append(dense_id)
        
        # Create output layer
        output_data = {
            "params": {"units": 10, "activation": "softmax"},  # 10 classes
            "prev_node": dense_id,
            "name": "cnn_output_layer"
        }
        output_response = self.client.post(dense_url, output_data, format="json")
        output_id = output_response.data.get("node_id")
        layers.append(output_id)
        
        return layers
    
    def _cleanup_cnn_layers(self, layers):
        """Helper method to clean up CNN layers"""
        # Clean up layers in reverse order
        for layer_id in reversed(layers):
            # Try different CNN endpoints
            endpoints = ['/api/create_input/', '/api/conv2d/', '/api/maxpool2d/', 
                        '/api/flatten/', '/api/dense/']
            for endpoint in endpoints:
                try:
                    self.client.delete(endpoint, format="json", query_params={"node_id": layer_id})
                    break
                except:
                    continue

    def test_input_layer_creation(self):
        """Test creation of Input layer"""
        url = '/api/create_input/'
        data = {
            "params": {"shape": [4]},  # 4 features for iris dataset
            "name": "input_layer"
        }
        response = self.client.post(url, data, format="json")
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data.get("node_name"), "input_layer")
        self.assertIsNotNone(response.data.get("node_id"))
        
        # Clean up
        node_id = response.data.get("node_id")
        self.client.delete(url, format="json", query_params={"node_id": node_id})

    def test_dense_layer_creation(self):
        """Test creation of Dense layer"""
        # First create an input layer
        input_url = '/api/create_input/'
        input_data = {
            "params": {"shape": [4]},
            "name": "input_layer"
        }
        input_response = self.client.post(input_url, input_data, format="json")
        input_id = input_response.data.get("node_id")
        
        # Create dense layer
        dense_url = '/api/dense/'
        dense_data = {
            "params": {"units": 64, "activation": "relu"},
            "prev_node": input_id,
            "name": "dense_layer"
        }
        dense_response = self.client.post(dense_url, dense_data, format="json")
        
        self.assertEqual(dense_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(dense_response.data.get("node_name"), "dense_layer")
        self.assertIsNotNone(dense_response.data.get("node_id"))
        
        # Clean up
        dense_id = dense_response.data.get("node_id")
        self.client.delete(input_url, format="json", query_params={"node_id": input_id})
        self.client.delete(dense_url, format="json", query_params={"node_id": dense_id})

    def test_conv2d_layer_creation(self):
        """Test creation of Conv2D layer"""
        # Create input layer for images
        input_url = '/api/create_input/'
        input_data = {
            "params": {"shape": [28, 28, 1]},  # Example image shape
            "name": "input_layer"
        }
        input_response = self.client.post(input_url, input_data, format="json")
        input_id = input_response.data.get("node_id")
        
        # Create Conv2D layer
        conv_url = '/api/conv2d/'
        conv_data = {
            "params": {"filters": 32, "kernel_size": [3, 3], "activation": "relu"},
            "prev_node": input_id,
            "name": "conv2d_layer"
        }
        conv_response = self.client.post(conv_url, conv_data, format="json")
        
        self.assertEqual(conv_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(conv_response.data.get("node_name"), "conv2d_layer")
        self.assertIsNotNone(conv_response.data.get("node_id"))
        
        # Clean up
        conv_id = conv_response.data.get("node_id")
        self.client.delete(input_url, format="json", query_params={"node_id": input_id})
        self.client.delete(conv_url, format="json", query_params={"node_id": conv_id})

    def test_maxpool2d_layer_creation(self):
        """Test creation of MaxPool2D layer"""
        # Create input and conv2d layers first
        input_url = '/api/create_input/'
        input_data = {
            "params": {"shape": [28, 28, 1]},
            "name": "input_layer"
        }
        input_response = self.client.post(input_url, input_data, format="json")
        input_id = input_response.data.get("node_id")
        
        conv_url = '/api/conv2d/'
        conv_data = {
            "params": {"filters": 32, "kernel_size": [3, 3], "activation": "relu"},
            "prev_node": input_id,
            "name": "conv2d_layer"
        }
        conv_response = self.client.post(conv_url, conv_data, format="json")
        conv_id = conv_response.data.get("node_id")
        
        # Create MaxPool2D layer
        maxpool_url = '/api/maxpool2d/'
        maxpool_data = {
            "params": {"pool_size": [2, 2]},
            "prev_node": conv_id,
            "name": "maxpool2d_layer"
        }
        maxpool_response = self.client.post(maxpool_url, maxpool_data, format="json")
        
        self.assertEqual(maxpool_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(maxpool_response.data.get("node_name"), "maxpool2d_layer")
        self.assertIsNotNone(maxpool_response.data.get("node_id"))
        
        # Clean up
        maxpool_id = maxpool_response.data.get("node_id")
        self.client.delete(input_url, format="json", query_params={"node_id": input_id})
        self.client.delete(conv_url, format="json", query_params={"node_id": conv_id})
        self.client.delete(maxpool_url, format="json", query_params={"node_id": maxpool_id})

    def test_flatten_layer_creation(self):
        """Test creation of Flatten layer"""
        # Create input layer
        input_url = '/api/create_input/'
        input_data = {
            "params": {"shape": [28, 28, 1]},
            "name": "input_layer"
        }
        input_response = self.client.post(input_url, input_data, format="json")
        input_id = input_response.data.get("node_id")
        
        # Create Flatten layer
        flatten_url = '/api/flatten/'
        flatten_data = {
            "prev_node": input_id,
            "name": "flatten_layer"
        }
        flatten_response = self.client.post(flatten_url, flatten_data, format="json")
        
        self.assertEqual(flatten_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(flatten_response.data.get("node_name"), "flatten_layer")
        self.assertIsNotNone(flatten_response.data.get("node_id"))
        
        # Clean up
        flatten_id = flatten_response.data.get("node_id")
        self.client.delete(input_url, format="json", query_params={"node_id": input_id})
        self.client.delete(flatten_url, format="json", query_params={"node_id": flatten_id})

    def test_dropout_layer_creation(self):
        """Test creation of Dropout layer"""
        # Create input layer
        input_url = '/api/create_input/'
        input_data = {
            "params": {"shape": [4]},
            "name": "input_layer"
        }
        input_response = self.client.post(input_url, input_data, format="json")
        input_id = input_response.data.get("node_id")
        
        # Create Dropout layer
        dropout_url = '/api/dropout/'
        dropout_data = {
            "params": {"rate": 0.2},
            "prev_node": input_id,
            "name": "dropout_layer"
        }
        dropout_response = self.client.post(dropout_url, dropout_data, format="json")
        
        self.assertEqual(dropout_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(dropout_response.data.get("node_name"), "dropout_layer")
        self.assertIsNotNone(dropout_response.data.get("node_id"))
        
        # Clean up
        dropout_id = dropout_response.data.get("node_id")
        self.client.delete(input_url, format="json", query_params={"node_id": input_id})
        self.client.delete(dropout_url, format="json", query_params={"node_id": dropout_id})

    def test_sequential_model_creation(self):
        """Test creation of Sequential model"""
        # Create input layer
        input_url = '/api/create_input/'
        input_data = {
            "params": {"shape": [4]},
            "name": "input_layer"
        }
        input_response = self.client.post(input_url, input_data, format="json")
        input_id = input_response.data.get("node_id")
        
        # Create dense layer
        dense_url = '/api/dense/'
        dense_data = {
            "params": {"units": 64, "activation": "relu"},
            "prev_node": input_id,
            "name": "dense_layer"
        }
        dense_response = self.client.post(dense_url, dense_data, format="json")
        dense_id = dense_response.data.get("node_id")
        
        # Create output layer
        output_dense_data = {
            "params": {"units": 3, "activation": "softmax"},  # 3 classes for iris
            "prev_node": dense_id,
            "name": "output_layer"
        }
        output_response = self.client.post(dense_url, output_dense_data, format="json")
        output_id = output_response.data.get("node_id")
        
        # Create Sequential model
        sequential_url = '/api/sequential/'
        sequential_data = {
            "layer": output_id,
            "name": "sequential_model"
        }
        sequential_response = self.client.post(sequential_url, sequential_data, format="json")
        
        self.assertEqual(sequential_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(sequential_response.data.get("node_name"), "sequential_model")
        self.assertIsNotNone(sequential_response.data.get("node_id"))
        
        # Clean up
        sequential_id = sequential_response.data.get("node_id")
        self.client.delete(input_url, format="json", query_params={"node_id": input_id})
        self.client.delete(dense_url, format="json", query_params={"node_id": dense_id})
        self.client.delete(dense_url, format="json", query_params={"node_id": output_id})
        self.client.delete(sequential_url, format="json", query_params={"node_id": sequential_id})

    def test_model_compilation(self):
        """Test model compilation functionality"""
        # Create a simple sequential model
        layers = self._create_simple_neural_network()
        
        # Create Sequential model
        sequential_url = '/api/sequential/'
        sequential_data = {
            "layer": layers[-1],
            "name": "test_model"
        }
        sequential_response = self.client.post(sequential_url, sequential_data, format="json")
        model_id = sequential_response.data.get("node_id")
        
        # Compile the model
        compile_url = '/api/compile/'
        compile_data = {
            "params": {
                "optimizer": "adam",
                "loss": "sparse_categorical_crossentropy",
                "metrics": ["accuracy"]
            },
            "nn_model": model_id,
            "name": "compiled_model"
        }
        compile_response = self.client.post(compile_url, compile_data, format="json")
        
        self.assertEqual(compile_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(compile_response.data.get("node_name"), "model_compiler")
        self.assertIsNotNone(compile_response.data.get("node_id"))
        
        # Clean up
        compiled_id = compile_response.data.get("node_id")
        self._cleanup_neural_network(layers)
        self.client.delete(sequential_url, format="json", query_params={"node_id": model_id})
        self.client.delete(compile_url, format="json", query_params={"node_id": compiled_id})

    # def test_neural_network_training(self):
    #     """Test neural network training functionality"""
    #     # Create and compile a neural network
    #     layers = self._create_simple_neural_network()
        
    #     sequential_url = '/api/sequential/'
    #     sequential_data = {
    #         "layer": layers[-1],
    #         "name": "training_model"
    #     }
    #     sequential_response = self.client.post(sequential_url, sequential_data, format="json")
    #     model_id = sequential_response.data.get("node_id")
        
    #     compile_url = '/api/compile/'
    #     compile_data = {
    #         "params": {
    #             "optimizer": "adam",
    #             "loss": "sparse_categorical_crossentropy",
    #             "metrics": ["accuracy"]
    #         },
    #         "nn_model": model_id,
    #         "name": "compiled_model"
    #     }
    #     compile_response = self.client.post(compile_url, compile_data, format="json")
    #     compiled_id = compile_response.data.get("node_id")
        
    #     # Train the model
    #     fit_url = '/api/fit_net/'
    #     fit_data = {
    #         "params": {
    #             "epochs": 1,  # Small number for testing
    #             "batch_size": 1
    #         },
    #         "compiled_model": compiled_id,
    #         "X": self.X_train_cls,
    #         "y": self.y_train_cls,
    #         "name": "fitted_model"
    #     }
    #     fit_response = self.client.post(fit_url, fit_data, format="json")

    #     self.assertEqual(fit_response.status_code, status.HTTP_201_CREATED)
    #     self.assertEqual(fit_response.data.get("node_name"), "nn_fitter")
    #     self.assertIsNotNone(fit_response.data.get("node_id"))
        
    #     # Clean up
    #     fitted_id = fit_response.data.get("node_id")
    #     self._cleanup_neural_network(layers)
    #     self.client.delete(sequential_url, format="json", query_params={"node_id": model_id})
    #     self.client.delete(compile_url, format="json", query_params={"node_id": compiled_id})
    #     self.client.delete(fit_url, format="json", query_params={"node_id": fitted_id})

    # def test_complete_neural_network_pipeline(self):
    #     """Test complete neural network pipeline from creation to prediction"""
    #     # Create neural network layers
    #     layers = self._create_simple_neural_network()
        
    #     # Create Sequential model
    #     sequential_url = '/api/sequential/'
    #     sequential_data = {
    #         "layer": layers[-1],
    #         "name": "complete_pipeline_model"
    #     }
    #     sequential_response = self.client.post(sequential_url, sequential_data, format="json")
    #     model_id = sequential_response.data.get("node_id")
    #     self.assertIsNotNone(model_id)
        
    #     # Compile the model
    #     compile_url = '/api/compile/'
    #     compile_data = {
    #         "params": {
    #             "optimizer": "adam",
    #             "loss": "sparse_categorical_crossentropy",
    #             "metrics": ["accuracy"]
    #         },
    #         "nn_model": model_id,
    #         "name": "compiled_model"
    #     }
    #     compile_response = self.client.post(compile_url, compile_data, format="json")
    #     compiled_id = compile_response.data.get("node_id")
    #     self.assertIsNotNone(compiled_id)
        
    #     # Train the model
    #     fit_url = '/api/fit_net/'
    #     fit_data = {
    #         "params": {
    #             "epochs": 1,
    #             "batch_size": 1
    #         },
    #         "compiled_model": compiled_id,
    #         "X": self.X_train_cls,
    #         "y": self.y_train_cls,
    #         "name": "fitted_model"
    #     }
    #     fit_response = self.client.post(fit_url, fit_data, format="json")
    #     fitted_id = fit_response.data.get("node_id")
    #     self.assertIsNotNone(fitted_id)
        
    #     # Make predictions
    #     predict_url = '/api/predict/'
    #     predict_data = {
    #         "X": self.X_test_cls,
    #         "fitted_model": fitted_id
    #     }
    #     predict_response = self.client.post(predict_url, predict_data, format="json")
    #     predictions_id = predict_response.data.get("node_id")
    #     self.assertIsNotNone(predictions_id)
        
    #     # Evaluate predictions
    #     evaluate_url = '/api/evaluate/'
    #     evaluate_data = {
    #         "params": {"metric": "accuracy"},
    #         "y_true": self.y_test_cls,
    #         "y_pred": predictions_id
    #     }
    #     evaluate_response = self.client.post(evaluate_url, evaluate_data, format="json")
    #     eval_id = evaluate_response.data.get("node_id")
    #     self.assertIsNotNone(eval_id)
        
    #     # Get evaluation results
    #     eval_result = self.client.get(evaluate_url, format="json", 
    #                                 query_params={"node_id": eval_id, "return_data": 1})
    #     accuracy = eval_result.data.get("node_data")
    #     self.assertIsNotNone(accuracy)
        
    #     print(f"\nNeural Network Pipeline Test - Accuracy: {accuracy*100:.2f}%")
        
    #     # Clean up
    #     self._cleanup_neural_network(layers)
    #     self.client.delete(sequential_url, format="json", query_params={"node_id": model_id})
    #     self.client.delete(compile_url, format="json", query_params={"node_id": compiled_id})
    #     self.client.delete(fit_url, format="json", query_params={"node_id": fitted_id})
    #     self.client.delete(predict_url, format="json", query_params={"node_id": predictions_id})
    #     self.client.delete(evaluate_url, format="json", query_params={"node_id": eval_id})
