from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework import status
from .utils import _requests_, _query_set_
from django.urls import reverse


# class PipeLineTest(APITestCase):
    
#     @classmethod
#     def setUp(cls):
#         super().setUpClass()

#     def test_01_model_loading(self, url='/api/create_model/', _requests_=_requests_['create_model']):
#         # POST: Create a linear regression model
#         ids = []
#         for data in _requests_['post']:
#             for query in _query_set_['post']:
#                 for value in query['values']:
#                     post_response = self.client.post(url, data, format="json", query_params={query['name']:value})
#                     self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
#                     self.assertEqual(post_response.data.get("node_name"), "logistic_regression")
#                     node_id = post_response.data.get("node_id")
#                     ids.append(node_id)
#                     self.assertIsNotNone(node_id)

#         # GET: Retrieve the created model using node_id
#         for query in _query_set_['get']:
#             for i, value in enumerate(query['values']):
#                 get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
#                 self.assertEqual(get_response.status_code, status.HTTP_200_OK)

#         # PUT: Update the model to logistic regression
#         for data in _requests_['put']:
#             for query in _query_set_['put']:
#                 for i, value in enumerate(query['values']):
#                     put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i], query['name']:value})
#                     self.assertEqual(put_response.status_code, status.HTTP_200_OK)
#                     # Verify updated model details
#                     put_response = self.client.get(url, format="json", query_params={"node_id":ids[i]})
#                     self.assertEqual(put_response.data.get("node_name"), "linear_regression")

#         # DELETE: Remove the model node using node_id
#         for node_id in ids[:-1]:
#             delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
#             self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)


#     def test_02_Data_loader(self, url='/api/data_loader/', _requests_=_requests_['data_loader']):
#         # POST: Create a data loader node
#         ids = []
#         for data in _requests_['post']:
#             for query in _query_set_['post']:
#                 for value in query['values']:
#                     post_response = self.client.post(url, data, format="json", query_params={query['name']:value})
#                     self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
#                     self.assertEqual(post_response.data.get("node_name"), "data_loader")
#                     node_id = post_response.data.get("node_id")
#                     ids.append(node_id)
#                     self.assertIsNotNone(node_id)

#         # GET: Retrieve the created data loader using node_id
#         for query in _query_set_['get']:
#             for i, value in enumerate(query['values']):
#                 get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
#                 self.assertEqual(get_response.status_code, status.HTTP_200_OK)

#         # PUT: Update the data loader to iris
#         for data in _requests_['put']:
#             for query in _query_set_['put']:
#                 for i, value in enumerate(query['values']):
#                     put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i], query['name']:value})
#                     self.assertEqual(put_response.status_code, status.HTTP_200_OK)
#                     # Verify updated model details
#                     put_response = self.client.get(f"{url}?node_id={ids[i]}", format="json")
#                     self.assertEqual(put_response.data.get("node_name"), "data_loader")

#         # DELETE: Remove the data loader node using node_id
#         # for node_id in ids[:-1]:
#         #     delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
#         #     self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)
        
    
#     def test_03_train_test_split(self, url='/api/train_test_split/', _requests_=_requests_['train_test_split']):
#         # POST: Create a train test split node
#         ids = []
#         data = self.client.post(f"/api/data_loader/",{"params": {"dataset_name":"diabetes"}}, format="json")
#         X = self.client.get(f"/api/data_loader/?node_id={data.data.get("node_id")}&output=1", format="json")
#         for data in _requests_['post']:
#             data.update({"data":X.data.get("node_id")})
#             for query in _query_set_['post']:
#                 for value in query['values']:
#                     post_response = self.client.post(url, data, format="json", query_params={query['name']:value})
#                     self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
#                     self.assertEqual(post_response.data.get("node_name"), "train_test_split")
#                     node_id = post_response.data.get("node_id")
#                     ids.append(node_id)
#                     self.assertIsNotNone(node_id)
        
#         # GET: Retrieve the created train test split using node_id
#         for query in _query_set_['get']:
#             for i, value in enumerate(query['values']):
#                 get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
#                 self.assertEqual(get_response.status_code, status.HTTP_200_OK)
        
#         # PUT: Update the train test split to 0.3 test size
#         for data in _requests_['put']:
#             data.update({"data":X.data.get("node_id")})
#             for query in _query_set_['put']:
#                 for i, value in enumerate(query['values']):
#                     put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i], query['name']:value})
#                     self.assertEqual(put_response.status_code, status.HTTP_200_OK)
#                     # Verify updated model details
#                     put_response = self.client.get(f"{url}?node_id={ids[i]}", format="json")
#                     self.assertEqual(put_response.data.get("node_name"), "train_test_split")

#         # DELETE: Remove the train test split node using node_id
#         # for node_id in ids[:-1]:
#         #     delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
#         #     self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)


class PipelineIntegrationTest(APITestCase):
    @classmethod
    def setUp(self):
        super().setUpClass()

    def test_04_logistic_regression_pipeline_with_iris(self):
        # Step 1: Load Iris Data
        url = reverse('data_loader')  # make sure to define your URL names accordingly
        data = {"params": {"dataset_name": "diabetes"}}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        response = self.client.put(url, {"params":{"dataset_name":"iris"}}, format='json', query_params={"node_id":response.data.get('node_id')})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data_loader_X, data_loader_y = response.data.get('children')
        self.assertIsNotNone(data_loader_X)
        self.assertIsNotNone(data_loader_y)


        # Step 2: Split the Data
        url = reverse('train_test_split')
        X = {
            "data": data_loader_X,
            "params":{"test_size": 0.3, "random_state": 42}
        }
        response = self.client.post(url, X, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        X_train, X_test = response.data.get('children')
        self.assertIsNotNone(X_train)
        self.assertIsNotNone(X_test)
        
        self.client.get(reverse('train_test_split'))

        y = {
            "data": data_loader_y,
            "params": {"test_size": 0.3, "random_state": 42}
        }
        response = self.client.post(url, y, format='json')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        y_train, y_test = response.data.get('children')
        self.assertIsNotNone(y_train)
        self.assertIsNotNone(y_test)


        # Step 3: Create Scaler Preprocessor
        url = reverse('create_preprocessor')
        data = {
            "preprocessor_name": "standard_scaler",
            "preprocessor_type": "scaler"
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        preprocessor_id = response.data.get('node_id')
        self.assertIsNotNone(preprocessor_id)

        # Step 4: Fit the Preprocessor
        url = reverse('fit_preprocessor')
        data = {
            "data": X_train,
            "preprocessor": preprocessor_id
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        fitted_preprocessor_id = response.data.get('node_id')
        self.assertIsNotNone(fitted_preprocessor_id)


        # Step 5: Transform the Data
        url = reverse('transform')
        data = {
            "data": X_train,
            "preprocessor": fitted_preprocessor_id
        }

        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        X_train = response.data.get('node_id')
        self.assertIsNotNone(X_train)

        data = {
            "data": X_test,
            "preprocessor": fitted_preprocessor_id
        }
        response = self.client.post(url, data, format='json')
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
        response = self.client.post(url, data, format='json')
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
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        fitted_model_id = response.data.get('node_id')
        self.assertIsNotNone(fitted_model_id)

        # Step 8: Generate Predictions
        url = reverse('predict_model')
        data = {
            "X": X_test,
            "model": fitted_model_id
        }
        response = self.client.post(url, data, format='json')
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
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        response = self.client.get(url, query_params={"node_id":response.data.get('node_id'), "return_data":1})
        score = response.data.get('node_data')
        self.assertIsNotNone(score)

        print(f"SCORE: {score*100} %") 

        self.client.delete(reverse('clear_nodes'))


