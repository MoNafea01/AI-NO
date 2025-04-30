from rest_framework.test import APITestCase
from rest_framework import status
from .utils import _requests_, _query_set_
from django.urls import reverse
import joblib

class PipeLineTest(APITestCase):
    
    @classmethod
    def setUp(cls):
        super().setUpClass()

    def test_01_model_loading(self, url='/api/create_model/', _requests_=_requests_['create_model']):
        ids = []
        # POST
        for data in _requests_['post']:
            post_response = self.client.post(url, data, format="json")
            self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
            self.assertEqual(post_response.data.get("node_name"), "logistic_regression")
            node_id = post_response.data.get("node_id")
            ids.append(node_id)
            self.assertIsNotNone(node_id)

        # GET
        for query in _query_set_['get']:
            for value in query['values']:
                for i in range(len(ids)):
                    get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
                    self.assertEqual(get_response.status_code, status.HTTP_200_OK)

        # PUT
        for data in _requests_['put']:
            for i in range(len(ids)):
                put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.status_code, status.HTTP_200_OK)
                # Verify updated model details
                put_response = self.client.get(url, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.data.get("node_name"), "linear_regression")

        # DELETE
        for node_id in ids:
            delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
            self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)


    def test_02_Data_loader(self, url='/api/data_loader/', _requests_=_requests_['data_loader']):
        ids = []
        # POST
        for data in _requests_['post']:
            post_response = self.client.post(url, data, format="json")
            self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
            self.assertEqual(post_response.data.get("node_name"), "data_loader")
            node_id = post_response.data.get("node_id")
            ids.append(node_id)
            self.assertIsNotNone(node_id)

        # GET
        for query in _query_set_['get']:
            for value in query['values']:
                for i in range(len(ids)):
                    get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
                    self.assertEqual(get_response.status_code, status.HTTP_200_OK)

        # PUT
        for data in _requests_['put']:
            for i in range(len(ids)):
                put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.status_code, status.HTTP_200_OK)
                # Verify updated model details
                put_response = self.client.get(url, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.data.get("node_name"), "data_loader")

        # DELETE
        for node_id in ids:
            delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
            self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)


    def test_03_train_test_split(self, url='/api/train_test_split/', _requests_=_requests_['train_test_split']):
        ids = []
        data = self.client.post(f"/api/data_loader/",{"params": {"dataset_name":"diabetes"}}, format="json")
        node_id = data.data.get("node_id")
        data = self.client.get(f"/api/data_loader/", format="json", query_params={"node_id":node_id, "return_data": 1})
        X, y = data.data.get("children")

        # POST
        for data in _requests_['post']:
            data.update({"X": X, "y": y})
            post_response = self.client.post(url, data, format="json")
            self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
            self.assertEqual(post_response.data.get("node_name"), "train_test_split")
            node_id = post_response.data.get("node_id")
            ids.append(node_id)
            self.assertIsNotNone(node_id)

        # GET
        for query in _query_set_['get']:
            for value in query['values']:
                for i in range(len(ids)):
                    get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
                    self.assertEqual(get_response.status_code, status.HTTP_200_OK)

        # PUT
        for data in _requests_['put']:
            data.update({"X": X, "y": y})
            for i in range(len(ids)):
                put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.status_code, status.HTTP_200_OK)
                # Verify updated model details
                put_response = self.client.get(url, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.data.get("node_name"), "train_test_split")
        
        # DELETE
        for node_id in ids:
            delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
            self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)


    def test_04_model_fitter(self, url='/api/fit_model/', _requests_=_requests_['fit_model']):
        ids = []
        data = self.client.post(f"/api/data_loader/",{"params": {"dataset_name":"diabetes"}}, format="json")
        node_id = data.data.get("node_id")

        data = self.client.get(f"/api/data_loader/", format="json", query_params={"node_id":node_id, "return_data": 1})

        X, y = data.data.get("children")
        model = self.client.post(f"/api/create_model/", {"model_name": "logistic_regression","model_type": "linear_models","task": "classification"}, format="json").data.get("node_id")

        # POST
        for data in _requests_['post']:
            if not data.get("model_path"):
                data.update({"model":model})

            data.update({"X": X, "y": y})
            post_response = self.client.post(url, data, format="json")
            self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
            self.assertEqual(post_response.data.get("node_name"), "model_fitter")
            node_id = post_response.data.get("node_id")
            ids.append(node_id)
            self.assertIsNotNone(node_id)

        # GET
        for query in _query_set_['get']:
            for value in query['values']:
                for i in range(len(ids)):
                    get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
                    self.assertEqual(get_response.status_code, status.HTTP_200_OK)

        # PUT
        for data in _requests_['put']:
            if not data.get("model_path"):
                data.update({"model":model})

            data.update({"X": X, "y": y})
            for i in range(len(ids)):
                put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.status_code, status.HTTP_200_OK)
                # Verify updated model details
                put_response = self.client.get(url, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.data.get("node_name"), "model_fitter")

        # DELETE
        for node_id in ids:
            delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
            self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)


    def test_05_model_predictor(self, url='/api/predict/', _requests_=_requests_['predict_model']):
        ids = []
        data = self.client.post(f"/api/data_loader/",{"params": {"dataset_name":"iris"}}, format="json")
        node_id = data.data.get("node_id")

        data = self.client.get(f"/api/data_loader/", format="json", query_params={"node_id":node_id, "return_data": 1})
        X, y = data.data.get("children")

        data = self.client.post(f"/api/train_test_split/", {"X": X, "y": y, "params": {"test_size": 0.2, "random_state": 42}}, format="json")

        data = self.client.get(f"/api/train_test_split/", format="json", query_params={"node_id":data.data.get("node_id"), "return_data": 1})
        (X_train, X_test),(y_train, y_test) = data.data.get("node_data")

       
        model = self.client.post(f"/api/create_model/", {"model_name": "logistic_regression","model_type": "linear_models","task": "classification"}, format="json").data.get("node_id")
        model = self.client.post(f"/api/fit_model/", {"X": X_train, "y": y_train, "model": model}, format="json").data.get("node_id")

        # POST
        for data in _requests_['post']:
            if not data.get("model_path"):
                data.update({"model":model})

            data.update({"X": X_test})
            post_response = self.client.post(url, data, format="json")
            self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
            self.assertEqual(post_response.data.get("node_name"), "predictor")
            node_id = post_response.data.get("node_id")
            ids.append(node_id)
            self.assertIsNotNone(node_id)

        # GET
        for query in _query_set_['get']:
            for value in query['values']:
                for i in range(len(ids)):
                    get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
                    self.assertEqual(get_response.status_code, status.HTTP_200_OK)

        # PUT
        for data in _requests_['put']:
            if not data.get("model_path"):
                data.update({"model":model})

            data.update({"X": X_test})
            for i in range(len(ids)):
                put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.status_code, status.HTTP_200_OK)
                # Verify updated model details
                put_response = self.client.get(url, format="json", query_params={"node_id":ids[i]})
                self.assertEqual(put_response.data.get("node_name"), "predictor")

        # DELETE
        for node_id in ids:
            delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
            self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)


    # def test_06_evaluate(self, url='/api/evaluate/', _requests_=_requests_['evaluate_model']):
    #     ids = []
    #     data = self.client.post(f"/api/data_loader/",{"params": {"dataset_name":"iris"}}, format="json")
    #     node_id = data.data.get("node_id")

    #     data = self.client.get(f"/api/data_loader/", format="json", query_params={"node_id":node_id, "return_data": 1})
    #     X, y = data.data.get("children")

    #     data = self.client.post(f"/api/train_test_split/", {"X": X, "y": y, "params": {"test_size": 0.2, "random_state": 42}}, format="json")

    #     data = self.client.get(f"/api/train_test_split/", format="json", query_params={"node_id":data.data.get("node_id"), "return_data": 1})
    #     X, y = data.data.get("children")
    #     (X_train, X_test),(y_train, y_test) = data.data.get("node_data")
        
    #     model = self.client.post(f"/api/create_model/", {"model_name": "logistic_regression","model_type": "linear_models","task": "classification"}, format="json").data.get("node_id")

    #     model = self.client.post(f"/api/fit_model/", {"X": X_train, "y": y_train, "model": model}, format="json").data.get("node_id")

    #     y_pred = self.client.post(f"/api/predict/", {"X": X_test, "model": model}, format="json").data.get("node_id")

    #     data = self.client.post(f"/api/splitter/", {"data": y} , format="json")
    #     y_train, y_test = data.data.get("children")
    #     # POST
    #     for data in _requests_['post']:
    #         data.update({"y_pred": y_pred, "y_true": y_test})

    #         post_response = self.client.post(url, data, format="json")
    #         self.assertEqual(post_response.status_code, status.HTTP_201_CREATED)
    #         self.assertEqual(post_response.data.get("node_name"), "evaluator")
    #         node_id = post_response.data.get("node_id")
    #         ids.append(node_id)
    #         self.assertIsNotNone(node_id)

    #     # GET
    #     for query in _query_set_['get']:
    #         for value in query['values']:
    #             for i in range(len(ids)):
    #                 get_response = self.client.get(url, format="json", query_params={"node_id":ids[i], query['name']:value})
    #                 self.assertEqual(get_response.status_code, status.HTTP_200_OK)

    #     # PUT
    #     for data in _requests_['put']:
    #         data.update({"y_pred": y_pred, "y_true": y_test})

    #         for i in range(len(ids)):
    #             put_response = self.client.put(url, data, format="json", query_params={"node_id":ids[i]})
    #             self.assertEqual(put_response.status_code, status.HTTP_200_OK)
    #             # Verify updated model details
    #             put_response = self.client.get(url, format="json", query_params={"node_id":ids[i]})
    #             self.assertEqual(put_response.data.get("node_name"), "evaluator")

    #     # DELETE
    #     for node_id in ids:
    #         delete_response = self.client.delete(url, format="json", query_params={"node_id":node_id})
    #         self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)


    def test_07_clear_nodes(self, url='/api/clear_nodes/'):
        # Clear all nodes
        response = self.client.delete(url, format="json")
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)


# class PipelineIntegrationTest(APITestCase):
#     @classmethod
#     def setUp(self):
#         super().setUpClass()

#     def test_04_logistic_regression_pipeline_with_iris(self):
#         # Step 1: Load Iris Data
#         url = reverse('data_loader')  # make sure to define your URL names accordingly
#         print("DATA LOADER URL:", url)

#         data = {"params": {"dataset_name": "diabetes"}}
#         response = self.client.post(url, data, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         response = self.client.put(url, {"params":{"dataset_name":"iris"}}, format='json', query_params={"node_id":response.data.get('node_id')})
#         self.assertEqual(response.status_code, status.HTTP_200_OK)
#         data_loader_X, data_loader_y = response.data.get('children')
#         self.assertIsNotNone(data_loader_X)
#         self.assertIsNotNone(data_loader_y)


#         # Step 2: Split the Data
#         url = reverse('train_test_split')
#         X = {
#             "data": data_loader_X,
#             "params":{"test_size": 0.3, "random_state": 42}
#         }
#         response = self.client.post(url, X, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         X_train, X_test = response.data.get('children')
#         self.assertIsNotNone(X_train)
#         self.assertIsNotNone(X_test)
        
#         self.client.get(reverse('train_test_split'))

#         y = {
#             "data": data_loader_y,
#             "params": {"test_size": 0.3, "random_state": 42}
#         }
#         response = self.client.post(url, y, format='json')

#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         y_train, y_test = response.data.get('children')
#         self.assertIsNotNone(y_train)
#         self.assertIsNotNone(y_test)


#         # Step 3: Create Scaler Preprocessor
#         url = reverse('create_preprocessor')
#         data = {
#             "preprocessor_name": "standard_scaler",
#             "preprocessor_type": "scaler"
#         }
#         response = self.client.post(url, data, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         preprocessor_id = response.data.get('node_id')
#         self.assertIsNotNone(preprocessor_id)

#         # Step 4: Fit the Preprocessor
#         url = reverse('fit_transform')
#         data = {
#             "data": X_train,
#             "preprocessor": preprocessor_id
#         }
#         response = self.client.post(url, data, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         fitted_preprocessor_id, X_train = response.data.get('children')
#         self.assertIsNotNone(fitted_preprocessor_id)
#         self.assertIsNotNone(X_train)

#         url = reverse('transform')
#         data = {
#             "data": X_test,
#             "preprocessor": fitted_preprocessor_id
#         }
#         response = self.client.post(url, data, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         X_test = response.data.get('node_id')
#         self.assertIsNotNone(X_test)

#         # Step 6: Create Logistic Regression Model
#         url = reverse('create_model')
#         data = {
#             "model_name": "logistic_regression",
#             "model_type": "linear_models",
#             "task": "classification"
#         }
#         response = self.client.post(url, data, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         model_id = response.data.get('node_id')
#         self.assertIsNotNone(model_id)


#         # Step 7: Fit the Model
#         url = reverse('fit_model')
#         data = {
#             "X": X_train,
#             "y": y_train,
#             "model": model_id
#         }
#         response = self.client.post(url, data, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         fitted_model_id = response.data.get('node_id')
#         self.assertIsNotNone(fitted_model_id)

#         # Step 8: Generate Predictions
#         url = reverse('predict_model')
#         data = {
#             "X": X_test,
#             "model": fitted_model_id
#         }
#         response = self.client.post(url, data, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         predictions_id = response.data.get('node_id')
#         self.assertIsNotNone(predictions_id)


#         # Step 9: Evaluate the Results
#         url = reverse('evaluate')
#         data = {
#             "params": {"metric": "accuracy"},
#             "y_true": y_test,
#             "y_pred": predictions_id
#         }
#         response = self.client.post(url, data, format='json')
#         self.assertEqual(response.status_code, status.HTTP_201_CREATED)
#         response = self.client.get(url, query_params={"node_id":response.data.get('node_id'), "return_path":1})
#         score = response.data.get('node_data')
#         score = joblib.load(score)
#         self.assertIsNotNone(score)

#         print(f"SCORE: {score*100} %") 

#         self.client.delete(reverse('clear_nodes'), query_params={"test":1})

# class Testing_Functions(APITestCase):
    # @classmethod
    # def setUp(self):
    #     super().setUpClass()

    # def test_01_test_function(self):

    #     def update_child(node:dict):
    #         l = []
    #         children_ids = node.get('children')
    #         if len(children_ids) >= 1:
    #             for i, child_id in enumerate(node.get('children')):
    #                 child = self.client.get('/api/create_model/', query_params={"node_id":child_id}).data
    #                 child['node_id'] = id(child)
    #                 node['children'][i] = child['node_id']
    #                 print(f"child {i}: {child.get('node_id')}")
    #                 l.append(child['node_id'])
    #                 update_child(child)
    #         node.update({"children": l, "node_id": id(node)})
    #         return node


    #     node = self.client.post('/api/create_input/', {'params':{'shape': [4]}}, format='json').data
    #     print(f"input_layer_id: {node.get('node_id')}")
    #     node = self.client.post('/api/dense/', {'prev_node': node.get('node_id')}, format='json').data
    #     print(f"dense__id: {node.get('node_id')}")
    #     node = self.client.post('/api/dense/', {'prev_node': node.get('node_id')}, format='json').data
    #     print(f"dense_2_id: {node.get('node_id')}")

    #     update_child(node)
    #     # print(l)
    #     print(node)