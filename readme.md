# AI-NO: Node-Based Machine Learning Workflow System

AI-NO is a comprehensive machine learning workflow management platform that enables users to create, manage, and execute ML pipelines through visual node-based interfaces and command-line tools.

## Overview

AI-NO provides multiple interfaces for building machine learning workflows:
- **Visual Node Editor**: Flutter-based desktop application for drag-and-drop workflow creation
- **Command Line Interface**: Terminal-based workflow management and automation [1](#0-0) 
- **Custom File Format**: `.ainoprj` format for project serialization with optional encryption

## Key Features

### Multi-Interface Support
- **GUI**: Flutter desktop application with visual node editor
- **CLI**: Full-featured command-line interface for scripting and automation [2](#0-1) 
- **API**: Django REST API backend for all operations

### Project Management
- User authentication and project isolation
- Project creation, selection, and management [3](#0-2) 
- Persistent session state across CLI sessions

### Machine Learning Capabilities
- Support for scikit-learn models and preprocessing
- Node-based workflow construction
- Model training, evaluation, and prediction pipelines [4](#0-3) 

### Data Formats
- Custom `.ainoprj` file format for project persistence
- JSON-based data interchange
- AES encryption support for sensitive workflows

## Installation

### Requirements
The project requires Python 3.12+ and includes comprehensive ML dependencies:

```bash
pip install -r requirements.txt
```

Key dependencies include:
- Django 5.2 for backend API
- scikit-learn 1.6.1 for ML operations
- TensorFlow 2.19.0 for deep learning
- pandas, numpy for data processing [5](#0-4) 

## Quick Start

### Command Line Interface

1. **Start the CLI**:
```bash
python cli/main.py
```

2. **Create a user**:
```bash
aino register username password
```

3. **Create a project**:
```bash
aino create_project my_project
```

4. **Create ML nodes**:
```bash
aino make logistic_regression {"penalty": "l1", "C": 1.0}
```

### Available Commands

#### User Management
- `register <username> <password>` - Create new user
- `login <username> <password>` - Login to existing user
- `make_admin <username>` - Grant admin privileges

#### Project Management  
- `create_project <name>` - Create new project
- `select_project <id>` - Switch to project
- `list_projects` - Show all projects [6](#0-5) 

#### Node Management
- `make <node_name> <params>` - Create ML node
- `edit <node_name> <id> <params>` - Modify existing node
- `show <node_name> <id>` - Display node details
- `list` - Show all nodes in project

## Architecture

### System Components
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter GUI   │    │   CLI Interface │    │  Django API     │
│                 │    │                 │    │                 │
│ Visual Workflow │◄──►│ Command Line    │◄──►│ REST Endpoints  │
│ Node Editor     │    │ Automation      │    │ Data Persistence│
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                ▲                       ▲
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │ Local JSON      │    │ Database        │
                       │ Session State   │    │ (PostgreSQL)    │
                       └─────────────────┘    └─────────────────┘
```

### Data Flow
- CLI commands are processed through specialized handlers
- API requests communicate with Django backend
- Local state is maintained in JSON format for session persistence
- Projects are serialized to `.ainoprj` format for portability

## Testing

The project includes comprehensive testing infrastructure:

### Automated Testing
- GitHub Actions CI/CD pipeline with PostgreSQL integration
- Django test suite execution
- Python 3.12.10 compatibility testing [7](#0-6) 

### Development Testing
- Jupyter notebook-based ML workflow testing
- scikit-learn integration validation
- Model persistence and loading verification

## File Formats

### AINOPRJ Format
Custom text-based format for workflow persistence:
```
AINOPRJ_START
NODE_START
node_id=123=int
displayed_name=LogisticRegression=str
params={"penalty": "l1"}=dict
NODE_END
AINOPRJ_END
```

Supports AES-256-CBC encryption for sensitive workflows.

## Contributing

The project follows a modular architecture with clear separation between:
- Frontend interfaces (Flutter, CLI)
- Backend API (Django)
- Data persistence layers
- ML workflow execution

## License

[License information not available in provided context]

## Support

For command reference, use:
```bash
aino help
```

This displays all available commands with their parameters and aliases.

## Notes

This README is based on the current codebase structure. The project appears to be actively developed with both visual and programmatic interfaces for ML workflow management. The CLI provides comprehensive functionality that mirrors the GUI capabilities, making it suitable for both interactive development and automated deployment scenarios.

Wiki pages you might want to explore:
- [Command Line Interface (MoNafea01/AI-NO)](/wiki/MoNafea01/AI-NO#4.2)
- [Custom Data Formats and Testing (MoNafea01/AI-NO)](/wiki/MoNafea01/AI-NO#6.3)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/MoNafea01/AI-NO)
