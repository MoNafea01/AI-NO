-- Create custom types
CREATE TYPE data_type AS ENUM ('string', 'number', 'boolean', 'object', 'array', 'null');

-- Users table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Projects table
CREATE TABLE Projects (
    project_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(user_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Workflows table
CREATE TABLE Workflows (
    workflow_id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES Projects(project_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Block prototypes table
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

-- Input ports table
CREATE TABLE InputPorts (
    port_id SERIAL PRIMARY KEY,
    prototype_id INTEGER REFERENCES BlockPrototypes(prototype_id),
    name VARCHAR(50) NOT NULL,
    data_type data_type NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    can_have_multiple_connections BOOLEAN DEFAULT FALSE,
    order_index INTEGER NOT NULL,
    description TEXT,
    UNIQUE (prototype_id, name)
);

-- Output ports table
CREATE TABLE OutputPorts (
    port_id SERIAL PRIMARY KEY,
    prototype_id INTEGER REFERENCES BlockPrototypes(prototype_id),
    name VARCHAR(50) NOT NULL,
    data_type data_type NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    can_have_multiple_connections BOOLEAN DEFAULT FALSE,
    order_index INTEGER NOT NULL,
    description TEXT,
    UNIQUE (prototype_id, name)
);

-- Workflow blocks table
CREATE TABLE WorkflowBlocks (
    block_id SERIAL PRIMARY KEY,
    workflow_id INTEGER REFERENCES Workflows(workflow_id),
    prototype_id INTEGER REFERENCES BlockPrototypes(prototype_id),
    position_x FLOAT,
    position_y FLOAT,
    parameters JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Block connections table
CREATE TABLE BlockConnections (
    connection_id SERIAL PRIMARY KEY,
    source_block_id INTEGER REFERENCES WorkflowBlocks(block_id),
    source_port_id INTEGER REFERENCES OutputPorts(port_id),
    target_block_id INTEGER REFERENCES WorkflowBlocks(block_id),
    target_port_id INTEGER REFERENCES InputPorts(port_id),
    output_key VARCHAR(50),
    input_key VARCHAR(50),
    UNIQUE (target_block_id, target_port_id)
);

-- Object instances table
CREATE TABLE ObjectInstances (
    instance_id SERIAL PRIMARY KEY,
    workflow_id INTEGER REFERENCES Workflows(workflow_id),
    prototype_id INTEGER REFERENCES BlockPrototypes(prototype_id),
    state JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for foreign keys and commonly queried fields
CREATE INDEX idx_projects_user_id ON Projects(user_id);
CREATE INDEX idx_workflows_project_id ON Workflows(project_id);
CREATE INDEX idx_workflow_blocks_workflow_id ON WorkflowBlocks(workflow_id);
CREATE INDEX idx_workflow_blocks_prototype_id ON WorkflowBlocks(prototype_id);
CREATE INDEX idx_input_ports_prototype_id ON InputPorts(prototype_id);
CREATE INDEX idx_output_ports_prototype_id ON OutputPorts(prototype_id);
CREATE INDEX idx_block_connections_source ON BlockConnections(source_block_id, source_port_id);
CREATE INDEX idx_block_connections_target ON BlockConnections(target_block_id, target_port_id);
CREATE INDEX idx_object_instances_workflow_id ON ObjectInstances(workflow_id);