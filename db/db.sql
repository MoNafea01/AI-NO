-- Create tables with proper relationships and constraints

CREATE TABLE WORKFLOWS (
    workflow_id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) CHECK (status IN ('draft', 'running', 'completed', 'failed', 'paused'))
);

CREATE TABLE NODE_TEMPLATES (
    template_id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    operation_type VARCHAR(100) NOT NULL,
    description TEXT
);



CREATE TABLE WORKFLOW_NODES (
    workflow_node_id VARCHAR(255) PRIMARY KEY,
    workflow_id VARCHAR(255) REFERENCES WORKFLOWS(workflow_id),
    template_id VARCHAR(255) REFERENCES NODE_TEMPLATES(template_id),
    model_instance_id VARCHAR(255) REFERENCES MODEL_INSTANCES(model_id),
    position_x INTEGER,
    position_y INTEGER,
    execution_order INTEGER,
    properties JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PORT_DEFINITIONS (
    port_id VARCHAR(255) PRIMARY KEY,
    template_id VARCHAR(255) REFERENCES NODE_TEMPLATES(template_id),
    name VARCHAR(255) NOT NULL,
    port_type VARCHAR(50) CHECK (port_type IN ('input', 'output')),
    data_type VARCHAR(50) NOT NULL,
    is_required BOOLEAN DEFAULT true
);

CREATE TABLE PARAMETER_DEFINITIONS (
    param_id VARCHAR(255) PRIMARY KEY,
    template_id VARCHAR(255) REFERENCES NODE_TEMPLATES(template_id),
    name VARCHAR(255) NOT NULL,
    data_type VARCHAR(50) NOT NULL,
    default_value TEXT,
    is_required BOOLEAN DEFAULT true
);

CREATE TABLE WORKFLOW_NODE_PORTS (
    port_instance_id VARCHAR(255) PRIMARY KEY,
    workflow_node_id VARCHAR(255) REFERENCES WORKFLOW_NODES(workflow_node_id),
    port_definition_id VARCHAR(255) REFERENCES PORT_DEFINITIONS(port_id),
    current_value JSONB,
    is_connected BOOLEAN DEFAULT false
);

CREATE TABLE CONNECTIONS (
    connection_id VARCHAR(255) PRIMARY KEY,
    workflow_id VARCHAR(255) REFERENCES WORKFLOWS(workflow_id),
    source_port_instance_id VARCHAR(255) REFERENCES WORKFLOW_NODE_PORTS(port_instance_id),
    target_port_instance_id VARCHAR(255) REFERENCES WORKFLOW_NODE_PORTS(port_instance_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX idx_workflow_nodes_workflow ON WORKFLOW_NODES(workflow_id);
CREATE INDEX idx_workflow_nodes_template ON WORKFLOW_NODES(template_id);
CREATE INDEX idx_workflow_nodes_model ON WORKFLOW_NODES(model_instance_id);
CREATE INDEX idx_node_ports_workflow_node ON WORKFLOW_NODE_PORTS(workflow_node_id);
CREATE INDEX idx_connections_workflow ON CONNECTIONS(workflow_id);

-- Insert sample data

-- Workflows
INSERT INTO WORKFLOWS (workflow_id, name, description, status) VALUES
('w1', 'iris_classification', 'Iris flower classification workflow', 'completed');

-- Node templates
INSERT INTO NODE_TEMPLATES (template_id, name, category, operation_type, description) VALUES 
('t11', 'Input', 'Other', 'Operation', 'Input node for data');
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


-- Workflow nodes with model instances
INSERT INTO WORKFLOW_NODES (workflow_node_id, workflow_id, template_id, model_instance_id, position_x, position_y, execution_order) VALUES
('wn11', 'w1', 't11', null, 50, 100, 1);   -- Input node
('wn3', 'w1', 't5', null, 200, 100, 4);   -- TrainTestSplit
('wn1', 'w1', 't1', 'm1', 100, 100, 2);   -- StandardScaler
('wn4', 'w1', 't9', null, 300, 100, 5);   -- FitTransform (for train data)
('wn5', 'w1', 't10', null, 400, 100, 6),  -- Transform (for test data)
('wn2', 'w1', 't2', 'm2', 100, 200, 3),   -- LogisticRegression
('wn6', 'w1', 't3', null, 500, 100, 7),   -- Fit
('wn7', 'w1', 't4', null, 600, 100, 8),   -- Predict
('wn8', 'w1', 't6', null, 700, 100, 9),   -- AccuracyScore
('wn9', 'w1', 't7', null, 700, 200, 10),   -- ConfusionMatrix
('wn10', 'w1', 't8', null, 700, 300, 11); -- ClassificationReport


-- Port definitions
INSERT INTO PORT_DEFINITIONS (port_id, template_id, name, port_type, data_type, is_required) VALUES
-- Input ports (instance)
('p33', 't11', 'X', 'output', 'matrix', true),
('p34', 't11', 'y', 'output', 'vector', true),
('p35', 't11', 'feature_names', 'output', 'Other', true),
('p36', 't11', 'target_names', 'output', 'Other', true);
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


-- Workflow node ports
INSERT INTO WORKFLOW_NODE_PORTS (port_instance_id, workflow_node_id, port_definition_id, current_value, is_connected) VALUES
--Input node
('wp33', 'wn11', 'p33', null, true),  -- X output
('wp34', 'wn11', 'p34', null, true),  -- y output
('wp35', 'wn11', 'p35', null, true),  -- feature_names output
('wp36', 'wn11', 'p36', null, true);  -- target_names output
-- TrainTestSplit
('wp3', 'wn3', 'p10', null, true),  -- X input
('wp4', 'wn3', 'p11', null, true),  -- y input
('wp5', 'wn3', 'p12', null, true),  -- X_train output
('wp6', 'wn3', 'p13', null, true),  -- X_test output
('wp7', 'wn3', 'p14', null, true),  -- y_train output
('wp8', 'wn3', 'p15', null, true);  -- y_test output
-- StandardScaler
('wp1', 'wn1', 'p1', 'm1', true),  -- instance output
-- fit_transform
('wp9', 'wn4', 'p26', null, true),   -- transformer input
('wp10', 'wn4', 'p27', null, true),  -- X input
('wp11', 'wn4', 'p28', null, true),  -- transformed_X output
('wp12', 'wn4', 'p29', null, true);  -- fitted_transformer output
-- tranform
('wp13', 'wn5', 'p30', null, true),  -- transformer input
('wp14', 'wn5', 'p31', null, true),  -- X input
('wp15', 'wn5', 'p32', null, true),  -- transformed_X output
-- LogisticRegression
('wp2', 'wn2', 'p2', 'm2', true),  -- instance output
-- fit
('wp16', 'wn6', 'p3', null, true),  -- model input
('wp17', 'wn6', 'p4', null, true),  -- X input
('wp18', 'wn6', 'p5', null, true),  -- y input
('wp19', 'wn6', 'p6', null, true),  -- fitted_model output
-- predict
('wp20', 'wn7', 'p7', null, true),  -- model input
('wp21', 'wn7', 'p8', null, true),  -- X input
('wp22', 'wn7', 'p9', null, true),  -- predictions outp
-- accuracy score
('wp23', 'wn8', 'p16', null, true),  -- y_true input
('wp24', 'wn8', 'p17', null, true),  -- y_pred input
('wp25', 'wn8', 'p18', null, true),  -- score output
-- confusion matrix
('wp26', 'wn9', 'p19', null, true),  -- y_true input
('wp27', 'wn9', 'p20', null, true),  -- y_pred input
('wp28', 'wn9', 'p21', null, true),  -- matrix output
-- classification report
('wp29', 'wn10', 'p22', null, true),  -- y_true input
('wp30', 'wn10', 'p23', null, true),  -- y_pred input
('wp31', 'wn10', 'p24', '{"target_names": ["setosa", "versicolor", "virginica"]}', true),  -- target_names input
('wp32', 'wn10', 'p25', null, true);  -- report output

-- Connections
INSERT INTO CONNECTIONS (connection_id, workflow_id, source_port_instance_id, target_port_instance_id) VALUES
('c16', 'w1', 'wp33', 'wp3'),  -- Connect X output to TrainTestSplit X input
('c17', 'w1', 'wp34', 'wp4'),  -- Connect y output to TrainTestSplit y input
('c18', 'w1', 'wp36', 'wp31'); -- Connect target_names to ClassificationReport target_names input
('c2', 'w1', 'wp5', 'wp17'),   -- X_train -> Fit X input
('c3', 'w1', 'wp6', 'wp21'),   -- X_test -> Transform X input
('c4', 'w1', 'wp7', 'wp18'),   -- y_train -> Fit y input
('c5', 'w1', 'wp8', 'wp23'),   -- y_test -> AccuracyScore y_true
('c6', 'w1', 'wp8', 'wp26'),   -- y_test -> ConfusionMatrix y_true
('c7', 'w1', 'wp8', 'wp29');   -- y_test -> ClassificationReport y_true
('c1', 'w1', 'wp1', 'wp9'),    -- StandardScaler instance -> FitTransform transformer input
('c5', 'w1', 'wp11', 'wp17'),  -- transformed X_train -> Fit X input
('c6', 'w1', 'wp12', 'wp13');  -- fitted transformer -> Transform transformer input
('c9', 'w1', 'wp15', 'wp21'),  -- transformed X_test -> Predict X input
('c7', 'w1', 'wp2', 'wp16'),   -- LogisticRegression instance -> Fit model input
('c8', 'w1', 'wp19', 'wp20'),  -- fitted model -> Predict model input
('c10', 'w1', 'wp8', 'wp23'),  -- y_test -> AccuracyScore y_true
('c13', 'w1', 'wp22', 'wp24'), -- predictions -> AccuracyScore y_pred
('c11', 'w1', 'wp8', 'wp26'),  -- y_test -> ConfusionMatrix y_true
('c14', 'w1', 'wp22', 'wp27'), -- predictions -> ConfusionMatrix y_pred
('c12', 'w1', 'wp8', 'wp29'),  -- y_test -> ClassificationReport y_true
('c15', 'w1', 'wp22', 'wp30'); -- predictions -> ClassificationReport y_pred