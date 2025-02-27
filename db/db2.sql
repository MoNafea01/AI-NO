-- Create tables
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Projects (
    project_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(user_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Workflows (
    workflow_id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES Projects(project_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

CREATE TABLE BlockPrototypes (
    prototype_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('function', 'object', 'object_method')) NOT NULL,
    input_schema JSONB,
    output_schema JSONB,
    parameter_schema JSONB,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE BlockPrototypePorts (
    port_id SERIAL PRIMARY KEY,
    prototype_id INTEGER REFERENCES BlockPrototypes(prototype_id),
    name VARCHAR(50) NOT NULL,
    port_type port_type NOT NULL,
    data_type data_type NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    can_have_multiple_connections BOOLEAN DEFAULT FALSE,
    order_index INTEGER NOT NULL,
    description TEXT,
    UNIQUE (prototype_id, name, port_type)
);

CREATE TABLE WorkflowBlocks (
    block_id SERIAL PRIMARY KEY,
    workflow_id INTEGER REFERENCES Workflows(workflow_id),
    prototype_id INTEGER REFERENCES BlockPrototypes(prototype_id),
    position_x FLOAT,
    position_y FLOAT,
    parameters JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE BlockConnections (
    connection_id SERIAL PRIMARY KEY,
    source_block_id INTEGER REFERENCES WorkflowBlocks(block_id),
    source_port_name VARCHAR(50) NOT NULL,
    target_block_id INTEGER REFERENCES WorkflowBlocks(block_id),
    target_port_name VARCHAR(50) NOT NULL,
    output_key VARCHAR(50),
    input_key VARCHAR(50)
);

CREATE TABLE ObjectInstances (
    instance_id SERIAL PRIMARY KEY,
    workflow_id INTEGER REFERENCES Workflows(workflow_id),
    prototype_id INTEGER REFERENCES BlockPrototypes(prototype_id),
    state JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert block prototypes for Iris classification workflow
INSERT INTO BlockPrototypes (name, category, type, input_schema, output_schema, parameter_schema) VALUES
-- Data Loading
('load_iris', 'data', 'function',
 '{}',
 '{"X": "ndarray", "y": "ndarray", "feature_names": "list", "target_names": "list"}',
 '{}'),

-- Data Splitting
('train_test_split', 'preprocessing', 'function',
 '{"X": "ndarray", "y": "ndarray"}',
 '{"X_train": "ndarray", "X_test": "ndarray", "y_train": "ndarray", "y_test": "ndarray"}',
 '{"test_size": "float", "random_state": "int"}'),

-- Preprocessing
('StandardScaler', 'preprocessing', 'object',
 '{}',
 '{"scaler": "StandardScaler"}',
 '{}'),

('fit_transform', 'preprocessing', 'object_method',
 '{"X": "ndarray", "scaler": "StandardScaler"}',
 '{"X_transformed": "ndarray"}',
 '{}'),

('transform', 'preprocessing', 'object_method',
 '{"X": "ndarray", "scaler": "StandardScaler"}',
 '{"X_transformed": "ndarray"}',
 '{}'),

-- Model
('LogisticRegression', 'model', 'object',
 '{}',
 '{"model": "LogisticRegression"}',
 '{}'),

('fit', 'model', 'object_method',
 '{"X": "ndarray", "y": "ndarray", "model": "LogisticRegression"}',
 '{"fitted_model": "LogisticRegression"}',
 '{}'),

('predict', 'model', 'object_method',
 '{"X": "ndarray", "model": "LogisticRegression"}',
 '{"y_pred": "ndarray"}',
 '{}'),

-- Metrics
('accuracy_score', 'metrics', 'function',
 '{"y_true": "ndarray", "y_pred": "ndarray"}',
 '{"accuracy": "float"}',
 '{}'),

('confusion_matrix', 'metrics', 'function',
 '{"y_true": "ndarray", "y_pred": "ndarray"}',
 '{"matrix": "ndarray"}',
 '{}'),

('classification_report', 'metrics', 'function',
 '{"y_true": "ndarray", "y_pred": "ndarray"}',
 '{"report": "str"}',
 '{}');

-- Insert sample user
INSERT INTO Users (email, password_hash, name) VALUES
('example@example.com', 'hashed_password', 'Example User');

-- Insert sample project
INSERT INTO Projects (user_id, name, description) VALUES
(1, 'Iris Classification', 'Simple iris flower classification project');

-- Insert sample workflow
INSERT INTO Workflows (project_id, name, description) VALUES
(1, 'Basic Classification Pipeline', 'Standard classification workflow with preprocessing');

-- Insert workflow blocks for iris classification
INSERT INTO WorkflowBlocks (workflow_id, prototype_id, position_x, position_y, parameters) VALUES
(1, 1, 100, 100, '{}'),  -- load_iris
(1, 2, 250, 100, '{"test_size": 0.2, "random_state": 42}'),  -- train_test_split
(1, 3, 400, 100, '{}'),  -- StandardScaler
(1, 4, 550, 100, '{}'),  -- fit_transform
(1, 5, 700, 100, '{}'),  -- transform
(1, 6, 850, 100, '{}'),  -- LogisticRegression
(1, 7, 1000, 100, '{}'), -- fit
(1, 8, 1150, 100, '{}'), -- predict
(1, 9, 1300, 100, '{}'); -- accuracy_score

INSERT INTO BlockPrototypePorts (prototype_id, name, port_type, data_type, is_required, can_have_multiple_connections, order_index, description) VALUES
-- Concatenate block (example of multiple inputs/outputs)
(1, 'input_arrays', 'input', 'ndarray', true, true, 0, 'Multiple arrays to concatenate'),
(1, 'concatenated_array', 'output', 'ndarray', true, false, 0, 'Resulting concatenated array'),

-- Train test split (multiple outputs)
(2, 'X', 'input', 'ndarray', true, false, 0, 'Feature matrix'),
(2, 'y', 'input', 'ndarray', true, false, 1, 'Target vector'),
(2, 'X_train', 'output', 'ndarray', true, false, 0, 'Training features'),
(2, 'X_test', 'output', 'ndarray', true, false, 1, 'Testing features'),
(2, 'y_train', 'output', 'ndarray', true, false, 2, 'Training targets'),
(2, 'y_test', 'output', 'ndarray', true, false, 3, 'Testing targets'),

-- Model fit (multiple inputs)
(7, 'X_train', 'input', 'ndarray', true, false, 0, 'Training features'),
(7, 'y_train', 'input', 'ndarray', true, false, 1, 'Training targets'),
(7, 'sample_weight', 'input', 'ndarray', false, false, 2, 'Sample weights'),
(7, 'fitted_model', 'output', 'ndarray', true, false, 0, 'Fitted model object');

-- Insert object instances for StandardScaler and LogisticRegression
INSERT INTO ObjectInstances (workflow_id, prototype_id, state) VALUES
(1, 3, '{
    "scale_": [0.828, 0.434, 0.762, 0.355],
    "mean_": [5.843, 3.057, 3.758, 1.199],
    "var_": [0.685, 0.188, 0.581, 0.126],
    "n_samples_seen_": 120
}'::jsonb),  -- StandardScaler instance with fitted parameters

(1, 6, '{
    "coef_": [[0.523, -0.321, 1.248, -0.854],
              [-0.231, 0.784, -0.928, 0.413],
              [-0.292, -0.463, -0.320, 0.441]],
    "intercept_": [-0.123, 0.234, -0.111],
    "classes_": [0, 1, 2],
    "n_iter_": [52],
    "n_features_in_": 4
}'::jsonb);  -- LogisticRegression instance with fitted parameters

-- Insert connections between blocks
INSERT INTO BlockConnections (source_block_id, target_block_id, output_key, input_key) VALUES
(1, 2, 'X', 'X'),           -- load_iris -> train_test_split
(1, 2, 'y', 'y'),           -- load_iris -> train_test_split
(2, 4, 'X_train', 'X'),     -- train_test_split -> fit_transform
(2, 5, 'X_test', 'X'),      -- train_test_split -> transform
(4, 7, 'X_transformed', 'X'), -- fit_transform -> fit
(2, 7, 'y_train', 'y'),     -- train_test_split -> fit
(5, 8, 'X_transformed', 'X'), -- transform -> predict
(8, 9, 'y_pred', 'y_pred'), -- predict -> accuracy_score
(2, 9, 'y_test', 'y_true'); -- train_test_split -> accuracy_score

-- Create indexes for better performance
CREATE INDEX idx_workflow_blocks_workflow ON WorkflowBlocks(workflow_id);
CREATE INDEX idx_block_connections_source ON BlockConnections(source_block_id);
CREATE INDEX idx_block_connections_target ON BlockConnections(target_block_id);