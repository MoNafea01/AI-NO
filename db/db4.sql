-- Users table
CREATE TABLE Users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- Projects table
CREATE TABLE Projects (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Workflows table
CREATE TABLE Workflows (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (project_id) REFERENCES Projects(id) ON DELETE CASCADE
);

-- BlockPrototype table
CREATE TABLE BlockPrototype (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    task VARCHAR(100) NOT NULL,
    description TEXT
);

-- PortDefinition table
CREATE TABLE PortDefinition (
    id SERIAL PRIMARY KEY,
    prototype_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    port_type VARCHAR(50) NOT NULL,
    data_type VARCHAR(50) NOT NULL,
    is_required BOOLEAN DEFAULT false,
    FOREIGN KEY (prototype_id) REFERENCES BlockPrototype(id) ON DELETE CASCADE
);

-- ParameterDefinition table
CREATE TABLE ParameterDefinition (
    id SERIAL PRIMARY KEY,
    prototype_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    datatype VARCHAR(50) NOT NULL,
    default_value TEXT,
    is_required BOOLEAN DEFAULT false,
    FOREIGN KEY (prototype_id) REFERENCES BlockPrototype(id) ON DELETE CASCADE
);

-- WorkflowBlocks table
CREATE TABLE WorkflowBlocks (
    id SERIAL PRIMARY KEY,
    proto_id INTEGER NOT NULL,
    workflow_id INTEGER NOT NULL,
    position_x FLOAT NOT NULL,
    position_y FLOAT NOT NULL,
    execution_order INTEGER NOT NULL,
    FOREIGN KEY (proto_id) REFERENCES BlockPrototype(id),
    FOREIGN KEY (workflow_id) REFERENCES Workflows(id) ON DELETE CASCADE
);

-- WorkflowBlockPorts table
CREATE TABLE WorkflowBlockPorts (
    id SERIAL PRIMARY KEY,
    block_id INTEGER NOT NULL,
    port_def_id INTEGER NOT NULL,
    current_value TEXT,
    is_connected BOOLEAN DEFAULT false,
    FOREIGN KEY (block_id) REFERENCES WorkflowBlocks(id) ON DELETE CASCADE,
    FOREIGN KEY (port_def_id) REFERENCES PortDefinition(id)
);

-- WorkflowBlockParameter table
CREATE TABLE WorkflowBlockParameter (
    id SERIAL PRIMARY KEY,
    block_id INTEGER NOT NULL,
    param_def_id INTEGER NOT NULL,
    current_value TEXT,
    FOREIGN KEY (block_id) REFERENCES WorkflowBlocks(id) ON DELETE CASCADE,
    FOREIGN KEY (param_def_id) REFERENCES ParameterDefinition(id)
);

-- Connections table
CREATE TABLE Connections (
    id SERIAL PRIMARY KEY,
    workflow_id INTEGER NOT NULL,
    source_port_id INTEGER NOT NULL,
    target_port_id INTEGER NOT NULL,
    FOREIGN KEY (workflow_id) REFERENCES Workflows(id) ON DELETE CASCADE,
    FOREIGN KEY (source_port_id) REFERENCES WorkflowBlockPorts(id) ON DELETE CASCADE,
    FOREIGN KEY (target_port_id) REFERENCES WorkflowBlockPorts(id) ON DELETE CASCADE
);