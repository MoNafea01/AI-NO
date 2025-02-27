-- NODE_TEMPLATES table - now includes all operations as separate templates
INSERT INTO NODE_TEMPLATES (template_id, name, category, operation_type, description) VALUES 
('t1', 'StandardScaler', 'Other', 'Preprocessing', 'Standardizes features by removing mean and scaling to unit variance'),
('t2', 'LogisticRegression', 'LinearModels', 'Classification', 'Logistic regression classifier'),
('t3', 'Fit', 'Other', 'Operation', 'Fits a model to training data'),
('t4', 'Predict', 'Other', 'Operation', 'Makes predictions using a trained model'),
('t5', 'TrainTestSplit', 'Other', 'Operation', 'Splits data into training and test sets'),
('t6', 'AccuracyScore', 'Other', 'Metric', 'Calculates prediction accuracy'),
('t7', 'ConfusionMatrix', 'Other', 'Metric', 'Generates confusion matrix'),
('t8', 'ClassificationReport', 'Other', 'Metric', 'Generates detailed classification metrics'),
('t9', 'FitTransform', 'Other', 'Operation', 'Fits transformer and transforms data'),
('t10', 'Transform', 'Other', 'Operation', 'Transforms data using fitted transformer');
('t11', 'Input', 'Other', 'Operation', 'Input node for data');

-- PORT_DEFINITIONS table - defines inputs/outputs for each operation
INSERT INTO PORT_DEFINITIONS (port_id, template_id, name, port_type, data_type, is_required) VALUES
-- Input node ports
('p33', 't11', 'X', 'output', 'matrix', true),
('p34', 't11', 'y', 'output', 'vector', true),
('p35', 't11', 'feature_names', 'output', 'Other', true),
('p36', 't11', 'target_names', 'output', 'Other', true),
-- StandardScaler ports (instance)
('p1', 't1', 'instance', 'output', 'Other', true),

-- LogisticRegression ports (instance)
('p2', 't2', 'instance', 'output', 'Other', true),

-- Fit ports
('p3', 't3', 'model', 'input', 'Other', true),
('p4', 't3', 'X', 'input', 'matrix', true),
('p5', 't3', 'y', 'input', 'vector', true),
('p6', 't3', 'fitted_model', 'output', 'Other', true),

-- Predict ports
('p7', 't4', 'model', 'input', 'Other', true),
('p8', 't4', 'X', 'input', 'matrix', true),
('p9', 't4', 'predictions', 'output', 'vector', true),

-- TrainTestSplit ports
('p10', 't5', 'X', 'input', 'matrix', true),
('p11', 't5', 'y', 'input', 'vector', true),
('p12', 't5', 'X_train', 'output', 'matrix', true),
('p13', 't5', 'X_test', 'output', 'matrix', true),
('p14', 't5', 'y_train', 'output', 'vector', true),
('p15', 't5', 'y_test', 'output', 'vector', true),

-- AccuracyScore ports
('p16', 't6', 'y_true', 'input', 'vector', true),
('p17', 't6', 'y_pred', 'input', 'vector', true),
('p18', 't6', 'score', 'output', 'float', true),

-- ConfusionMatrix ports
('p19', 't7', 'y_true', 'input', 'vector', true),
('p20', 't7', 'y_pred', 'input', 'vector', true),
('p21', 't7', 'matrix', 'output', 'matrix', true),

-- ClassificationReport ports
('p22', 't8', 'y_true', 'input', 'vector', true),
('p23', 't8', 'y_pred', 'input', 'vector', true),
('p24', 't8', 'target_names', 'input', 'Other', false),
('p25', 't8', 'report', 'output', 'Other', true),

-- FitTransform ports
('p26', 't9', 'transformer', 'input', 'Other', true),
('p27', 't9', 'X', 'input', 'matrix', true),
('p28', 't9', 'transformed_X', 'output', 'matrix', true),
('p29', 't9', 'fitted_transformer', 'output', 'Other', true),

-- Transform ports
('p30', 't10', 'transformer', 'input', 'Other', true),
('p31', 't10', 'X', 'input', 'matrix', true),
('p32', 't10', 'transformed_X', 'output', 'matrix', true);

-- PARAMETER_DEFINITIONS table - parameters for each node type
INSERT INTO PARAMETER_DEFINITIONS (param_id, template_id, name, data_type, default_value, is_required) VALUES
-- StandardScaler parameters
('param1', 't1', 'with_mean', 'Other', 'true', true),
('param2', 't1', 'with_std', 'Other', 'true', true),

-- LogisticRegression parameters
('param3', 't2', 'C', 'float', '1.0', true),
('param4', 't2', 'max_iter', 'float', '100', false),

-- TrainTestSplit parameters
('param5', 't5', 'test_size', 'float', '0.2', false),
('param6', 't5', 'random_state', 'float', '42', false);

-- Example workflow instance (just a few nodes shown for brevity)
INSERT INTO WORKFLOWS (workflow_id, name, description, status) VALUES
('w1', 'iris_classification', 'Iris flower classification with separate operation nodes', 'completed');

-- WORKFLOW_NODES table - shows execution order of operations
INSERT INTO WORKFLOW_NODES (workflow_node_id, workflow_id, template_id, position_x, position_y, execution_order) VALUES
('wn11', 'w1', 't11', 'm3', 50, 100, 1);
('wn1', 'w1', 't1', 100, 100, 2),   -- StandardScaler
('wn2', 'w1', 't2', 100, 200, 3),   -- LogisticRegression
('wn3', 'w1', 't5', 200, 100, 4),   -- TrainTestSplit
('wn4', 'w1', 't9', 300, 100, 5),   -- FitTransform (for train data)
('wn5', 'w1', 't10', 400, 100, 6),  -- Transform (for test data)
('wn6', 'w1', 't3', 500, 100, 7),   -- Fit
('wn7', 'w1', 't4', 600, 100, 8),   -- Predict
('wn8', 'w1', 't6', 700, 100, 9),   -- AccuracyScore
('wn9', 'w1', 't7', 700, 200, 10),   -- ConfusionMatrix
('wn10', 'w1', 't8', 700, 300, 11); -- ClassificationReport

-- MODEL_INSTANCES table - stores the actual model objects
INSERT INTO MODEL_INSTANCES (model_id, template_id, name, parameters, state, model_artifacts) VALUES
('m1', 't1', 'iris_scaler', 
    '{"with_mean": true, "with_std": true}',
    'trained',
    '{"mean_": [5.843333, 3.057333, 3.758000, 1.199333], 
      "scale_": [0.828066, 0.435866, 1.764421, 0.762238]}'),

('m2', 't2', 'iris_classifier',
    '{"C": 1.0, "max_iter": 100}',
    'trained',
    '{"coef_": [[...]], "intercept_": [...], "classes_": [0, 1, 2]}');

-- WORKFLOW_NODE_PORTS table - instances of ports for each node in the workflow
INSERT INTO WORKFLOW_NODE_PORTS (port_instance_id, workflow_node_id, port_definition_id, current_value, is_connected) VALUES
-- Add port instances for Input node
('wp33', 'wn11', 'p33', null, true),  -- X output
('wp34', 'wn11', 'p34', null, true),  -- y output
('wp35', 'wn11', 'p35', null, true),  -- feature_names output
('wp36', 'wn11', 'p36', null, true);  -- target_names output

-- StandardScaler (wn1) ports
('wp1', 'wn1', 'p1', '{"model_id": "m1"}', true),  -- instance output

-- LogisticRegression (wn2) ports
('wp2', 'wn2', 'p2', '{"model_id": "m2"}', true),  -- instance output

-- TrainTestSplit (wn3) ports
('wp3', 'wn3', 'p10', null, true),  -- X input
('wp4', 'wn3', 'p11', null, true),  -- y input
('wp5', 'wn3', 'p12', null, true),  -- X_train output
('wp6', 'wn3', 'p13', null, true),  -- X_test output
('wp7', 'wn3', 'p14', null, true),  -- y_train output
('wp8', 'wn3', 'p15', null, true);  -- y_test output

-- FitTransform (wn4) ports
('wp9', 'wn4', 'p26', null, true),   -- transformer input
('wp10', 'wn4', 'p27', null, true),  -- X input
('wp11', 'wn4', 'p28', null, true),  -- transformed_X output
('wp12', 'wn4', 'p29', null, true),  -- fitted_transformer output

-- Transform (wn5) ports
('wp13', 'wn5', 'p30', null, true),  -- transformer input
('wp14', 'wn5', 'p31', null, true),  -- X input
('wp15', 'wn5', 'p32', null, true),  -- transformed_X output

-- Fit (wn6) ports
('wp16', 'wn6', 'p3', null, true),  -- model input
('wp17', 'wn6', 'p4', null, true),  -- X input
('wp18', 'wn6', 'p5', null, true),  -- y input
('wp19', 'wn6', 'p6', null, true),  -- fitted_model output

-- Predict (wn7) ports
('wp20', 'wn7', 'p7', null, true),  -- model input
('wp21', 'wn7', 'p8', null, true),  -- X input
('wp22', 'wn7', 'p9', null, true),  -- predictions output

-- AccuracyScore (wn8) ports
('wp23', 'wn8', 'p16', null, true),  -- y_true input
('wp24', 'wn8', 'p17', null, true),  -- y_pred input
('wp25', 'wn8', 'p18', null, true),  -- score output

-- ConfusionMatrix (wn9) ports
('wp26', 'wn9', 'p19', null, true),  -- y_true input
('wp27', 'wn9', 'p20', null, true),  -- y_pred input
('wp28', 'wn9', 'p21', null, true),  -- matrix output

-- ClassificationReport (wn10) ports
('wp29', 'wn10', 'p22', null, true),  -- y_true input
('wp30', 'wn10', 'p23', null, true),  -- y_pred input
('wp31', 'wn10', 'p24', '{"target_names": ["setosa", "versicolor", "virginica"]}', true),  -- target_names input
('wp32', 'wn10', 'p25', null, true);  -- report output

-- CONNECTIONS table - shows how data flows between nodes
INSERT INTO CONNECTIONS (connection_id, workflow_id, source_port_instance_id, target_port_instance_id) VALUES
-- Update connections to connect Input node to TrainTestSplit
('c16', 'w1', 'wp33', 'wp3'),  -- Connect X output to TrainTestSplit X input
('c17', 'w1', 'wp34', 'wp4'),  -- Connect y output to TrainTestSplit y input
('c18', 'w1', 'wp36', 'wp31'); -- Connect target_names to ClassificationReport target_names input

-- Connect StandardScaler instance to FitTransform
('c1', 'w1', 'wp1', 'wp9'),    -- StandardScaler instance -> FitTransform transformer input

-- Connect TrainTestSplit outputs to respective nodes
('c2', 'w1', 'wp5', 'wp17'),   -- X_train -> Fit X input
('c3', 'w1', 'wp6', 'wp21'),   -- X_test -> Transform X input
('c4', 'w1', 'wp7', 'wp18'),   -- y_train -> Fit y input
('c5', 'w1', 'wp8', 'wp23'),   -- y_test -> AccuracyScore y_true
('c6', 'w1', 'wp8', 'wp26'),   -- y_test -> ConfusionMatrix y_true
('c7', 'w1', 'wp8', 'wp29');   -- y_test -> ClassificationReport y_true

-- Connect FitTransform outputs
('c5', 'w1', 'wp11', 'wp17'),  -- transformed X_train -> Fit X input
('c6', 'w1', 'wp12', 'wp13'),  -- fitted transformer -> Transform transformer input

-- Connect LogisticRegression instance to Fit
('c7', 'w1', 'wp2', 'wp16'),   -- LogisticRegression instance -> Fit model input

-- Connect Fit output to Predict
('c8', 'w1', 'wp19', 'wp20'),  -- fitted model -> Predict model input

-- Connect Transform output to Predict
('c9', 'w1', 'wp15', 'wp21'),  -- transformed X_test -> Predict X input

-- Connect test set y to evaluation metrics
('c10', 'w1', 'wp8', 'wp23'),  -- y_test -> AccuracyScore y_true
('c11', 'w1', 'wp8', 'wp26'),  -- y_test -> ConfusionMatrix y_true
('c12', 'w1', 'wp8', 'wp29'),  -- y_test -> ClassificationReport y_true

-- Connect predictions to evaluation metrics
('c13', 'w1', 'wp22', 'wp24'), -- predictions -> AccuracyScore y_pred
('c14', 'w1', 'wp22', 'wp27'), -- predictions -> ConfusionMatrix y_pred
('c15', 'w1', 'wp22', 'wp30'); -- predictions -> ClassificationReport y_pred