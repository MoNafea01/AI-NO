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
aino --user register username password
```

3. **Create a project**:
```bash
aino --project create my_project description
```

4. **Create ML nodes**:
```bash
aino --node create logistic_regression penalty=l1 C=1.0
```

### Available Commands

#### User Management
- `--user register <username> <password>` - Create new user
- `--user login <username> <password>` - Login to existing user
- `--user make_admin <username>` - Grant admin privileges
- `--user remove <username>` - Remove a User

#### Project Management  
- `--project create <name> <description>` - Create new project
- `--project select <id>` - Switch to project
- `--project deselect` - deselect the current project
- `--project remove <id>` - Remove project
- `--project list` - Show all projects [6](#0-5)
- `--project clear <id>` - Clear Project Content
- `--project load <id>` - Loads a Project from API

#### Node Management
- `--node create <node_name> <args>` - Create ML node
- `--node edit <node_name> <id> <args>` - Modify existing node
- `--node remove <node_name> <id>` - Remove an existing node
- `--node show <node_name> <id>` - Display node details
- `--node list` - Show all nodes in project

## Architecture

### System Components
```
                       ┌─────────────────┐
                       │ Natural Language│
                       │                 │
                       │    AI Agent     │
                       └─────────────────┘
                               ▲
                               │
                               ▼
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
		node_id=1713756015072=int
		displayed_name=Conv2D Layer=str
		node_name=conv2d_layer=str
		message=Conv2D layer created=str
		params=[{'filters': 32}, {'kernel_size': [3, 3]}, {'strides': [1, 1]}, {'padding': 'valid'}, {'activation': 'relu'}]=dict
		children=[1713752969184]=list
		location_x=692.691909665341=int
		location_y=2755.5500376012906=int
		input_ports=[{'name': 'prev_node', 'connectedNode': {'name': 'layer', 'nodeData': 1713752969184}}]=list
		output_ports=[{'name': 'layer', 'nodeData': 1713756015072}]=list
		project=200=int
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
aino --general help
```

## Directory Tree
### Windows Flutter App
```
├── ai_gen
    ├── .gitignore
    ├── .metadata
    ├── README.md
    ├── analysis_options.yaml
    ├── android
    │   ├── .gitignore
    │   ├── app
    │   │   ├── .cxx
    │   │   │   └── Debug
    │   │   │   │   └── 3q6ku76b
    │   │   │   │       ├── arm64-v8a
    │   │   │   │           ├── CMakeCache.txt
    │   │   │   │           ├── CMakeFiles
    │   │   │   │           │   ├── 3.22.1-g37088a8-dirty
    │   │   │   │           │   │   ├── CMakeDetermineCompilerABI_C.bin
    │   │   │   │           │   │   ├── CMakeDetermineCompilerABI_CXX.bin
    │   │   │   │           │   │   ├── CompilerIdC
    │   │   │   │           │   │   │   ├── CMakeCCompilerId.c
    │   │   │   │           │   │   │   └── CMakeCCompilerId.o
    │   │   │   │           │   │   └── CompilerIdCXX
    │   │   │   │           │   │   │   ├── CMakeCXXCompilerId.cpp
    │   │   │   │           │   │   │   └── CMakeCXXCompilerId.o
    │   │   │   │           │   ├── TargetDirectories.txt
    │   │   │   │           │   ├── cmake.check_cache
    │   │   │   │           │   └── rules.ninja
    │   │   │   │           ├── additional_project_files.txt
    │   │   │   │           ├── android_gradle_build.json
    │   │   │   │           ├── android_gradle_build_mini.json
    │   │   │   │           ├── build.ninja
    │   │   │   │           ├── build_file_index.txt
    │   │   │   │           ├── configure_fingerprint.bin
    │   │   │   │           ├── metadata_generation_command.txt
    │   │   │   │           ├── prefab_config.json
    │   │   │   │           └── symbol_folder_index.txt
    │   │   │   │       ├── armeabi-v7a
    │   │   │   │           ├── CMakeCache.txt
    │   │   │   │           ├── CMakeFiles
    │   │   │   │           │   ├── 3.22.1-g37088a8-dirty
    │   │   │   │           │   │   ├── CMakeDetermineCompilerABI_C.bin
    │   │   │   │           │   │   ├── CMakeDetermineCompilerABI_CXX.bin
    │   │   │   │           │   │   ├── CompilerIdC
    │   │   │   │           │   │   │   ├── CMakeCCompilerId.c
    │   │   │   │           │   │   │   └── CMakeCCompilerId.o
    │   │   │   │           │   │   └── CompilerIdCXX
    │   │   │   │           │   │   │   ├── CMakeCXXCompilerId.cpp
    │   │   │   │           │   │   │   └── CMakeCXXCompilerId.o
    │   │   │   │           │   ├── TargetDirectories.txt
    │   │   │   │           │   ├── cmake.check_cache
    │   │   │   │           │   └── rules.ninja
    │   │   │   │           ├── additional_project_files.txt
    │   │   │   │           ├── android_gradle_build.json
    │   │   │   │           ├── android_gradle_build_mini.json
    │   │   │   │           ├── build.ninja
    │   │   │   │           ├── build_file_index.txt
    │   │   │   │           ├── configure_fingerprint.bin
    │   │   │   │           ├── metadata_generation_command.txt
    │   │   │   │           ├── prefab_config.json
    │   │   │   │           └── symbol_folder_index.txt
    │   │   │   │       ├── hash_key.txt
    │   │   │   │       ├── x86
    │   │   │   │           ├── CMakeCache.txt
    │   │   │   │           ├── CMakeFiles
    │   │   │   │           │   ├── 3.22.1-g37088a8-dirty
    │   │   │   │           │   │   ├── CMakeDetermineCompilerABI_C.bin
    │   │   │   │           │   │   ├── CMakeDetermineCompilerABI_CXX.bin
    │   │   │   │           │   │   ├── CompilerIdC
    │   │   │   │           │   │   │   ├── CMakeCCompilerId.c
    │   │   │   │           │   │   │   └── CMakeCCompilerId.o
    │   │   │   │           │   │   └── CompilerIdCXX
    │   │   │   │           │   │   │   ├── CMakeCXXCompilerId.cpp
    │   │   │   │           │   │   │   └── CMakeCXXCompilerId.o
    │   │   │   │           │   ├── TargetDirectories.txt
    │   │   │   │           │   ├── cmake.check_cache
    │   │   │   │           │   └── rules.ninja
    │   │   │   │           ├── additional_project_files.txt
    │   │   │   │           ├── android_gradle_build.json
    │   │   │   │           ├── android_gradle_build_mini.json
    │   │   │   │           ├── build.ninja
    │   │   │   │           ├── build_file_index.txt
    │   │   │   │           ├── configure_fingerprint.bin
    │   │   │   │           ├── metadata_generation_command.txt
    │   │   │   │           ├── prefab_config.json
    │   │   │   │           └── symbol_folder_index.txt
    │   │   │   │       └── x86_64
    │   │   │   │           ├── CMakeCache.txt
    │   │   │   │           ├── CMakeFiles
    │   │   │   │               ├── 3.22.1-g37088a8-dirty
    │   │   │   │               │   ├── CMakeDetermineCompilerABI_C.bin
    │   │   │   │               │   ├── CMakeDetermineCompilerABI_CXX.bin
    │   │   │   │               │   ├── CompilerIdC
    │   │   │   │               │   │   ├── CMakeCCompilerId.c
    │   │   │   │               │   │   └── CMakeCCompilerId.o
    │   │   │   │               │   └── CompilerIdCXX
    │   │   │   │               │   │   ├── CMakeCXXCompilerId.cpp
    │   │   │   │               │   │   └── CMakeCXXCompilerId.o
    │   │   │   │               ├── TargetDirectories.txt
    │   │   │   │               ├── cmake.check_cache
    │   │   │   │               └── rules.ninja
    │   │   │   │           ├── additional_project_files.txt
    │   │   │   │           ├── android_gradle_build.json
    │   │   │   │           ├── android_gradle_build_mini.json
    │   │   │   │           ├── build.ninja
    │   │   │   │           ├── build_file_index.txt
    │   │   │   │           ├── configure_fingerprint.bin
    │   │   │   │           ├── metadata_generation_command.txt
    │   │   │   │           ├── prefab_config.json
    │   │   │   │           └── symbol_folder_index.txt
    │   │   ├── build.gradle
    │   │   └── src
    │   │   │   ├── debug
    │   │   │       └── AndroidManifest.xml
    │   │   │   ├── main
    │   │   │       ├── AndroidManifest.xml
    │   │   │       ├── kotlin
    │   │   │       │   └── com
    │   │   │       │   │   └── example
    │   │   │       │   │       └── ai_gen
    │   │   │       │   │           └── MainActivity.kt
    │   │   │       └── res
    │   │   │       │   ├── drawable-v21
    │   │   │       │       └── launch_background.xml
    │   │   │       │   ├── drawable
    │   │   │       │       └── launch_background.xml
    │   │   │       │   ├── mipmap-hdpi
    │   │   │       │       └── ic_launcher.png
    │   │   │       │   ├── mipmap-mdpi
    │   │   │       │       └── ic_launcher.png
    │   │   │       │   ├── mipmap-xhdpi
    │   │   │       │       └── ic_launcher.png
    │   │   │       │   ├── mipmap-xxhdpi
    │   │   │       │       └── ic_launcher.png
    │   │   │       │   ├── mipmap-xxxhdpi
    │   │   │       │       └── ic_launcher.png
    │   │   │       │   ├── values-night
    │   │   │       │       └── styles.xml
    │   │   │       │   └── values
    │   │   │       │       └── styles.xml
    │   │   │   └── profile
    │   │   │       └── AndroidManifest.xml
    │   ├── build.gradle
    │   ├── gradle.properties
    │   ├── gradle
    │   │   └── wrapper
    │   │   │   └── gradle-wrapper.properties
    │   └── settings.gradle
    ├── assets
    │   ├── fonts
    │   │   └── roboto_fonts
    │   │   │   ├── Roboto-Black.ttf
    │   │   │   ├── Roboto-Bold.ttf
    │   │   │   ├── Roboto-Light.ttf
    │   │   │   ├── Roboto-Medium.ttf
    │   │   │   ├── Roboto-Regular.ttf
    │   │   │   └── Roboto-Thin.ttf
    │   └── images
    │   │   ├── Cloud Upload.png
    │   │   ├── Icon.png
    │   │   ├── ProjectLogo.png
    │   │   ├── Schema.png
    │   │   ├── add_icon.svg
    │   │   ├── apple_logo.png
    │   │   ├── architectures_icon.svg
    │   │   ├── arrow_Selector_Tool.png
    │   │   ├── chat_bot.svg
    │   │   ├── chat_bot_active.svg
    │   │   ├── data_sets.png
    │   │   ├── data_sets_icon.svg
    │   │   ├── docs.png
    │   │   ├── docs_icon.svg
    │   │   ├── expanded_icon.svg
    │   │   ├── explore.png
    │   │   ├── explore_icon.svg
    │   │   ├── export_icon.svg
    │   │   ├── facebook_logo.png
    │   │   ├── github_logo.png
    │   │   ├── google_logo.png
    │   │   ├── hand_Selector_Tool.jpeg
    │   │   ├── import_icon.svg
    │   │   ├── learn_icon.svg
    │   │   ├── leran_icon_screen.svg
    │   │   ├── log_out_icon.svg
    │   │   ├── model_icon.svg
    │   │   ├── network_nodes.png
    │   │   ├── notifications_icon.svg
    │   │   ├── profileImage.png
    │   │   ├── project_logo.svg
    │   │   ├── refresh.svg
    │   │   ├── school.png
    │   │   ├── settings.png
    │   │   └── settings_icon.svg
    ├── devtools_options.yaml
    ├── lib
    │   ├── core
    │   │   ├── data
    │   │   │   ├── cache
    │   │   │   │   ├── cache_data.dart
    │   │   │   │   ├── cache_helper.dart
    │   │   │   │   ├── cache_services
    │   │   │   │   │   └── cache_service.dart
    │   │   │   │   └── cahch_keys.dart
    │   │   │   └── network
    │   │   │   │   ├── api_error_handler.dart
    │   │   │   │   ├── network_constants.dart
    │   │   │   │   ├── network_helper.dart
    │   │   │   │   ├── server_manager
    │   │   │   │       └── server_manager.dart
    │   │   │   │   └── services
    │   │   │   │       ├── implementation
    │   │   │   │           ├── node_services.dart
    │   │   │   │           └── project_services.dart
    │   │   │   │       └── interfaces
    │   │   │   │           ├── node_services_interface.dart
    │   │   │   │           └── project_services_interface.dart
    │   │   ├── di
    │   │   │   ├── get_it_initialize.dart
    │   │   │   ├── network_module.dart
    │   │   │   └── service_module.dart
    │   │   ├── models
    │   │   │   ├── node_model
    │   │   │   │   ├── node_model.dart
    │   │   │   │   └── parameter_model.dart
    │   │   │   └── project_model.dart
    │   │   ├── translation
    │   │   │   ├── ar.dart
    │   │   │   ├── en.dart
    │   │   │   ├── translation_helper.dart
    │   │   │   └── translation_keys.dart
    │   │   └── utils
    │   │   │   ├── app_constants.dart
    │   │   │   ├── helper
    │   │   │       ├── bloc_observer.dart
    │   │   │       ├── check_main_args.dart
    │   │   │       ├── helper.dart
    │   │   │       └── my_windows_manager.dart
    │   │   │   ├── reusable_widgets
    │   │   │       ├── custom_button.dart
    │   │   │       ├── custom_dialog.dart
    │   │   │       ├── custom_menu_item.dart
    │   │   │       ├── custom_text_field.dart
    │   │   │       ├── custom_text_form_field.dart
    │   │   │       ├── failure_screen.dart
    │   │   │       ├── loading_screen.dart
    │   │   │       ├── pick_file_text_field.dart
    │   │   │       └── pick_folder_icon.dart
    │   │   │   └── themes
    │   │   │       ├── app_colors.dart
    │   │   │       ├── asset_paths.dart
    │   │   │       └── textstyles.dart
    │   ├── features
    │   │   ├── HomeScreen
    │   │   │   ├── cubit
    │   │   │   │   ├── dashboard_cubit
    │   │   │   │   │   ├── dash_board_cubit.dart
    │   │   │   │   │   └── dash_board_state.dart
    │   │   │   │   ├── home_cubit
    │   │   │   │   │   ├── home_cubit.dart
    │   │   │   │   │   └── home_state.dart
    │   │   │   │   ├── project_cubit.dart
    │   │   │   │   └── user_profile_cubit
    │   │   │   │   │   ├── user_profile_cubit.dart
    │   │   │   │   │   └── user_profile_state.dart
    │   │   │   ├── data
    │   │   │   │   ├── enum_app_screens.dart
    │   │   │   │   ├── project_item.dart
    │   │   │   │   ├── project_items.dart
    │   │   │   │   ├── repository
    │   │   │   │   │   └── project_repository.dart
    │   │   │   │   └── user_profile.dart
    │   │   │   ├── home_screen.dart
    │   │   │   ├── screens
    │   │   │   │   ├── home_screen.dart
    │   │   │   │   ├── new_dashboard_screen.dart
    │   │   │   │   └── profile_screen.dart
    │   │   │   └── widgets
    │   │   │   │   ├── build_dashboard_header.dart
    │   │   │   │   ├── build_profile_info.dart
    │   │   │   │   ├── build_side_bar_dashboard.dart
    │   │   │   │   ├── create_new_project_button.dart
    │   │   │   │   ├── create_new_project_dialog.dart
    │   │   │   │   ├── dialogs
    │   │   │   │       ├── delete_confirmation_dialog.dart
    │   │   │   │       └── delete_empty_projects_dialog.dart
    │   │   │   │   ├── edit_profile_dialog.dart
    │   │   │   │   ├── logout_btn.dart
    │   │   │   │   ├── profile_widget.dart
    │   │   │   │   └── projects_table
    │   │   │   │       ├── pagination_controls.dart
    │   │   │   │       ├── project_cells.dart
    │   │   │   │       ├── project_list_item.dart
    │   │   │   │       ├── projects_table.dart
    │   │   │   │       └── projects_table_header.dart
    │   │   ├── OtpVerificationScreen
    │   │   │   ├── otp_provider.dart
    │   │   │   └── otp_verification_screen.dart
    │   │   ├── SmallScreenWarning
    │   │   │   └── small_screen_warning.dart
    │   │   ├── architecturesScreen
    │   │   │   └── architecture_screen.dart
    │   │   ├── auth
    │   │   │   ├── cubit
    │   │   │   │   ├── auth_cubit.dart
    │   │   │   │   └── auth_state.dart
    │   │   │   ├── data
    │   │   │   │   ├── models
    │   │   │   │   │   └── user_model.dart
    │   │   │   │   └── services
    │   │   │   │   │   └── auth_services.dart
    │   │   │   └── presentation
    │   │   │   │   ├── pages
    │   │   │   │       ├── sign_in_screen.dart
    │   │   │   │       └── sign_up_screen.dart
    │   │   │   │   └── widgets
    │   │   │   │       ├── auth_provider.dart
    │   │   │   │       ├── custom_text_field.dart
    │   │   │   │       ├── outlinedPrimaryButton.dart
    │   │   │   │       ├── social_sign_in_button.dart
    │   │   │   │       └── user_testimonal.dart
    │   │   ├── change_password_screen
    │   │   │   ├── cubit
    │   │   │   │   ├── change_pass_cubit.dart
    │   │   │   │   ├── change_pass_event.dart
    │   │   │   │   └── change_pass_states.dart
    │   │   │   └── presntation
    │   │   │   │   ├── pages
    │   │   │   │       └── change_password_screen.dart
    │   │   │   │   └── widgets
    │   │   │   │       └── build_password_field.dart
    │   │   ├── datasetScreen
    │   │   │   ├── cubit
    │   │   │   │   ├── dataset_screen.dart
    │   │   │   │   └── dataset_screen_cubit.dart
    │   │   │   ├── screens
    │   │   │   │   └── dataset_screen.dart
    │   │   │   └── widgets
    │   │   │   │   ├── build_project_item.dart
    │   │   │   │   ├── dataset_card.dart
    │   │   │   │   └── show_project_dialog.dart
    │   │   ├── docsScreen
    │   │   │   ├── cubit
    │   │   │   │   ├── docsScreen_cubit.dart
    │   │   │   │   └── docsScreen_state.dart
    │   │   │   ├── docs_screen.dart
    │   │   │   └── widgets
    │   │   │   │   ├── build_empty_projects_list.dart
    │   │   │   │   ├── build_empty_state.dart
    │   │   │   │   ├── build_filter_dropdown.dart
    │   │   │   │   ├── build_project_card.dart
    │   │   │   │   ├── build_successful_state.dart
    │   │   │   │   ├── build_tag.dart
    │   │   │   │   └── copy_to_clip_board.dart
    │   │   ├── learnScreen
    │   │   │   └── learn_screen.dart
    │   │   ├── modelScreen
    │   │   │   ├── cubit
    │   │   │   │   ├── model_screen_cubit.dart
    │   │   │   │   └── model_screen_state.dart
    │   │   │   ├── screens
    │   │   │   │   └── model_screen.dart
    │   │   │   └── widgets
    │   │   │   │   ├── build_project_item.dart
    │   │   │   │   ├── model_card.dart
    │   │   │   │   └── show_project_dialog.dart
    │   │   ├── node_view
    │   │   │   ├── chatbot
    │   │   │   │   ├── controller
    │   │   │   │   │   └── chat_controller.dart
    │   │   │   │   ├── services
    │   │   │   │   │   └── chat_service.dart
    │   │   │   │   └── ui
    │   │   │   │   │   ├── chat_header.dart
    │   │   │   │   │   ├── chat_input_field.dart
    │   │   │   │   │   ├── chat_message_bubble.dart
    │   │   │   │   │   ├── chat_message_list.dart
    │   │   │   │   │   ├── chat_screen.dart
    │   │   │   │   │   └── chat_workflow_buttons.dart
    │   │   │   ├── cubit
    │   │   │   │   ├── grid_node_view_cubit.dart
    │   │   │   │   └── node_view_state.dart
    │   │   │   ├── data
    │   │   │   │   └── serialization
    │   │   │   │   │   └── node_serializer.dart
    │   │   │   └── presentation
    │   │   │   │   ├── grid_node_view.dart
    │   │   │   │   ├── node_builder
    │   │   │   │       ├── builder
    │   │   │   │       │   ├── interface_factory.dart
    │   │   │   │       │   ├── node_builder.dart
    │   │   │   │       │   └── node_factory.dart
    │   │   │   │       ├── custom_interfaces
    │   │   │   │       │   ├── README.md
    │   │   │   │       │   ├── aino_general_Interface.dart
    │   │   │   │       │   ├── base
    │   │   │   │       │   │   ├── base_interface.dart
    │   │   │   │       │   │   └── universal_accepted_types.dart
    │   │   │   │       │   ├── custom_interfaces.dart
    │   │   │   │       │   ├── fitter_interface.dart
    │   │   │   │       │   ├── interface_colors.dart
    │   │   │   │       │   ├── model_interface.dart
    │   │   │   │       │   ├── multi_output_interface.dart
    │   │   │   │       │   ├── network_interface.dart
    │   │   │   │       │   ├── node_loader_interface.dart
    │   │   │   │       │   ├── node_template_saver_interface.dart
    │   │   │   │       │   ├── preprocessor_interface.dart
    │   │   │   │       │   └── vs_text_input_data.dart
    │   │   │   │       └── node_builder.dart
    │   │   │   │   ├── node_view.dart
    │   │   │   │   ├── old_node_builder
    │   │   │   │       ├── _node_builder.dart
    │   │   │   │       ├── functions_subgroup
    │   │   │   │       │   └── functions_subgroup.dart
    │   │   │   │       ├── models_subgroup
    │   │   │   │       │   └── models_subgroup.dart
    │   │   │   │       └── old_apicalls
    │   │   │   │       │   ├── create_model.dart
    │   │   │   │       │   └── train_test_split.dart
    │   │   │   │   └── widgets
    │   │   │   │       ├── custom_button.dart
    │   │   │   │       ├── custom_fab.dart
    │   │   │   │       ├── legend.dart
    │   │   │   │       ├── menu_actions.dart
    │   │   │   │       ├── node_properties_widget
    │   │   │   │           ├── node_properties_card.dart
    │   │   │   │           ├── param_dropdown_menu.dart
    │   │   │   │           ├── param_input.dart
    │   │   │   │           ├── param_multi_select_menu.dart
    │   │   │   │           ├── param_num_input.dart
    │   │   │   │           ├── param_select_path.dart
    │   │   │   │           └── param_text_field.dart
    │   │   │   │       ├── node_view_actions
    │   │   │   │           ├── custom_top_action.dart
    │   │   │   │           └── node_selector_menu.dart
    │   │   │   │       └── run_button.dart
    │   │   ├── request_otp_screen
    │   │   │   └── presentation
    │   │   │   │   └── pages
    │   │   │   │       └── request_otp_screen.dart
    │   │   ├── resetting_password_screen
    │   │   │   └── presentation
    │   │   │   │   └── pages
    │   │   │   │       └── resetting_password_screen.dart
    │   │   ├── screens
    │   │   │   └── HomeScreen
    │   │   │   │   ├── cubit
    │   │   │   │       ├── home_cubit.dart
    │   │   │   │       └── home_state.dart
    │   │   │   │   ├── home_screen.dart
    │   │   │   │   └── widgets
    │   │   │   │       ├── custom_icon_text_button.dart
    │   │   │   │       ├── header_section.dart
    │   │   │   │       ├── main_content.dart
    │   │   │   │       ├── profile_section.dart
    │   │   │   │       ├── project_actions
    │   │   │   │           ├── create_new_project_dialog.dart
    │   │   │   │           ├── export_project_dialog.dart
    │   │   │   │           └── import_project_dialog.dart
    │   │   │   │       ├── project_table.dart
    │   │   │   │       ├── search_and_action.dart
    │   │   │   │       ├── side_bar_widget.dart
    │   │   │   │       ├── sidebar_icon.dart
    │   │   │   │       └── sidebar_icon_app.dart
    │   │   ├── settings_screen
    │   │   │   ├── appearence_screen.dart
    │   │   │   ├── cubits
    │   │   │   │   ├── change_language_cubit
    │   │   │   │   │   ├── language_cubit.dart
    │   │   │   │   │   └── language_state.dart
    │   │   │   │   ├── settings_cubit.dart
    │   │   │   │   └── theme_cubit
    │   │   │   │   │   ├── theme_cubit.dart
    │   │   │   │   │   └── theme_state.dart
    │   │   │   ├── language_screen.dart
    │   │   │   ├── settings_screen.dart
    │   │   │   └── widgets
    │   │   │   │   ├── build_tap.dart
    │   │   │   │   └── custom_language_container.dart
    │   │   ├── splashScreen
    │   │   │   └── splash_screen.dart
    │   │   └── verify_otp_screen-for_password
    │   │   │   └── presentation
    │   │   │       └── pages
    │   │   │           └── verify_otp_for_password_screen.dart
    │   ├── local_pcakages
    │   │   └── vs_node_view
    │   │   │   ├── common.dart
    │   │   │   ├── data
    │   │   │       ├── evaluation_error.dart
    │   │   │       ├── offset_extension.dart
    │   │   │       ├── standard_interfaces
    │   │   │       │   ├── vs_bool_interface.dart
    │   │   │       │   ├── vs_double_interface.dart
    │   │   │       │   ├── vs_dynamic_interface.dart
    │   │   │       │   ├── vs_int_interface.dart
    │   │   │       │   ├── vs_num_interface.dart
    │   │   │       │   └── vs_string_interface.dart
    │   │   │       ├── vs_history_manager.dart
    │   │   │       ├── vs_interface.dart
    │   │   │       ├── vs_node_data.dart
    │   │   │       ├── vs_node_data_provider.dart
    │   │   │       ├── vs_node_manager.dart
    │   │   │       ├── vs_node_serialization_manager.dart
    │   │   │       └── vs_subgroup.dart
    │   │   │   ├── special_nodes
    │   │   │       ├── vs_list_node.dart
    │   │   │       ├── vs_output_node.dart
    │   │   │       └── vs_widget_node.dart
    │   │   │   ├── vs_node_view.dart
    │   │   │   └── widgets
    │   │   │       ├── grid_painter
    │   │   │           ├── grid_painter.dart
    │   │   │           └── grid_painter_class.dart
    │   │   │       ├── inherited_node_data_provider.dart
    │   │   │       ├── interactive_vs_node_view.dart
    │   │   │       ├── line_drawer
    │   │   │           ├── gradiant_line_drawer.dart
    │   │   │           └── multi_gradiant_line_drawer.dart
    │   │   │       ├── vs_context_menu.dart
    │   │   │       ├── vs_node_view.dart
    │   │   │       ├── vs_node_widget
    │   │   │           ├── node_content.dart
    │   │   │           ├── test_container.dart
    │   │   │           ├── transparent_sides_painter.dart
    │   │   │           ├── vs_node.dart
    │   │   │           ├── vs_node_input.dart
    │   │   │           ├── vs_node_output.dart
    │   │   │           └── vs_node_title.dart
    │   │   │       └── vs_selection_area.dart
    │   ├── main.dart
    │   └── test
    │   │   ├── node_view_example.dart
    │   │   └── presentation
    │   │       ├── cubits
    │   │           ├── grid_node_view_cubit.dart
    │   │           └── node_view_state.dart
    │   │       ├── grid_node_view.dart
    │   │       ├── node_builder
    │   │           ├── custom_interfaces
    │   │           │   ├── aino_general_Interface.dart
    │   │           │   ├── data_loader_interface.dart
    │   │           │   ├── interface_colors.dart
    │   │           │   ├── model_interface.dart
    │   │           │   ├── multi_output_interface.dart
    │   │           │   ├── preprocessor_interface.dart
    │   │           │   └── vs_text_input_data.dart
    │   │           └── node_builder.dart
    │   │       ├── old_node_builder
    │   │           ├── _node_builder.dart
    │   │           ├── functions_subgroup
    │   │           │   └── functions_subgroup.dart
    │   │           ├── models_subgroup
    │   │           │   └── models_subgroup.dart
    │   │           └── old_apicalls
    │   │           │   ├── create_model.dart
    │   │           │   └── train_test_split.dart
    │   │       ├── test_node_view.dart
    │   │       └── widgets
    │   │           └── legend.dart
    ├── pubspec.lock
    ├── pubspec.yaml
    ├── run_server.bat
    ├── shorebird.yaml
    ├── test
    │   └── widget_test.dart
    ├── web
    │   ├── favicon.png
    │   ├── icons
    │   │   ├── Icon-192.png
    │   │   ├── Icon-512.png
    │   │   ├── Icon-maskable-192.png
    │   │   └── Icon-maskable-512.png
    │   ├── index.html
    │   └── manifest.json
    └── windows
       ├── .gitignore
       ├── CMakeLists.txt
       ├── flutter
           ├── CMakeLists.txt
           └── generated_plugin_registrant.h
       └── runner
           ├── CMakeLists.txt
           ├── RCa31108
           ├── Runner.rc
           ├── flutter_window.cpp
           ├── flutter_window.h
           ├── main.cpp
           ├── resource.h
           ├── resources
               └── app_icon.ico
           ├── runner.exe.manifest
           ├── utils.cpp
           ├── utils.h
           ├── win32_window.cpp
           └── win32_window.h
```
### AI Agent
```
├── chatbot
    ├── .gradio
    │   └── certificate.pem
    ├── __init__.py
    ├── agents
    │   ├── __init__.py
    │   ├── agents.py
    │   ├── feedback_agent.py
    │   ├── generation_agent.py
    │   ├── mode_selector_agent.py
    │   ├── orchestrator.py
    │   ├── retrieval_agent.py
    │   ├── router_agent.py
    │   └── steps_estimator.py
    ├── app.py
    ├── cb_utils.py
    ├── config
    │   └── config.yaml
    ├── core
    │   ├── __init__.py
    │   ├── docs.py
    │   ├── rag_pipeline.py
    │   ├── templates.py
    │   └── utils.py
    ├── main.py
    ├── pipeline.ipynb
    ├── res
    │   ├── Cli script guidebook.pdf
    │   ├── auto_mode_nodes.pdf
    │   ├── data_mapping.json
    │   ├── defaults.py
    │   └── steps.pdf
    ├── retriever_cache
    │   ├── auto
    │   │   ├── index.faiss
    │   │   └── index.pkl
    │   ├── auto_mode_nodes
    │   │   ├── index.faiss
    │   │   └── index.pkl
    │   ├── manual
    │   │   ├── index.faiss
    │   │   └── index.pkl
    │   ├── router
    │   │   ├── index.faiss
    │   │   └── index.pkl
    │   ├── selector
    │   │   ├── index.faiss
    │   │   └── index.pkl
    │   └── step
    │   │   ├── index.faiss
    │   │   └── index.pkl
    ├── templates
    │   ├── auto_template.txt
    │   ├── manual_template.txt
    │   ├── router_template.txt
    │   ├── select_mode_template.txt
    │   └── steps_estimate_template.txt
    └── utils.py
```
### Tool (Used by AI Agent to send API requests to the Desktop DRF for Node Management)
```
├── cli 
    ├── __init__.py
    ├── call_cli.py
    ├── data_store.json
    ├── handlers
    │   ├── node_handler.py
    │   ├── project_handler.py
    │   └── user_handler.py
    ├── main.py
    ├── save_load.py
    ├── test.py
    └── utils
    │   ├── defaults.py
    │   ├── help.txt
    │   ├── mapper.json
    │   └── mapper.py
```
### Desktop Backend (Based on Django Restful API. Applied Controller-Service-Repository Design Pattern)
```
├── project (Desktop Backend)
    ├── ai_operations
    │   ├── __init__.py
    │   ├── admin.py
    │   ├── apps.py
    │   ├── migrations
    │   │   ├── 0001_initial.py
    │   │   └── __init__.py
    │   ├── models.py
    │   ├── serializers.py
    │   ├── tests.py
    │   ├── urls.py
    │   ├── utils.py
    │   └── views.py
    ├── cb
    │   ├── apps.py
    │   ├── migrations
    │   │   ├── 0001_initial.py
    │   │   └── __init__.py
    │   └── models.py
    ├── core
    │   ├── __init__.py
    │   ├── blueprint
    │   │   └── nafea_template.pkl
    │   ├── data.csv
    │   ├── nodes
    │   │   ├── __init__.py
    │   │   ├── base_node.py
    │   │   ├── configs
    │   │   │   ├── const_.py
    │   │   │   ├── datasets.py
    │   │   │   ├── metrics.py
    │   │   │   ├── models.py
    │   │   │   └── preprocessors.py
    │   │   ├── ds.csv
    │   │   ├── model
    │   │   │   ├── __init__.py
    │   │   │   ├── evaluator.py
    │   │   │   ├── fit.py
    │   │   │   ├── model.py
    │   │   │   ├── predict.py
    │   │   │   ├── tempCodeRunnerFile.py
    │   │   │   └── utils.py
    │   │   ├── nets
    │   │   │   ├── __init__.py
    │   │   │   ├── base_layer.py
    │   │   │   ├── cnn_layers.py
    │   │   │   ├── compile.py
    │   │   │   ├── dnn_layers.py
    │   │   │   ├── fit.py
    │   │   │   ├── flatten_layer.py
    │   │   │   ├── input_layer.py
    │   │   │   ├── sequential.py
    │   │   │   └── utils.py
    │   │   ├── other
    │   │   │   ├── __init__.py
    │   │   │   ├── custom.py
    │   │   │   ├── dataLoader.py
    │   │   │   └── train_test_split.py
    │   │   ├── preprocessing
    │   │   │   ├── __init__.py
    │   │   │   ├── fit.py
    │   │   │   ├── fit_transform.py
    │   │   │   ├── preprocessor.py
    │   │   │   ├── transform.py
    │   │   │   └── utils.py
    │   │   └── utils.py
    │   ├── repositories
    │   │   ├── __init__.py
    │   │   ├── node_repository.py
    │   │   └── operations
    │   │   │   ├── __init__.py
    │   │   │   ├── delete.py
    │   │   │   ├── load.py
    │   │   │   ├── save.py
    │   │   │   └── update.py
    │   ├── schema.xlsx
    │   └── workflow_executer.py
    ├── data_mapping.json
    ├── exports
    │   └── exported_project.json
    ├── jsonAinoConverter.py
    ├── manage.py
    ├── project
    │   ├── __init__.py
    │   ├── asgi.py
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    ├── requirements.txt
    ├── sqlite_editor.ipynb
    ├── static
    │   ├── AICON.ico
    │   ├── AICON.png
    │   └── AINO.ico
    └── testing
    │   ├── *.csv
    │   ├── *.pkl
├── readme.md
├── requirements.txt
├── run_server.bat
├── setup_project.bat
├── test.ipynb
```
### Website Backend
```
└── website (Backend)
    └── backend
        ├── .gitignore
        ├── accounts
            ├── __init__.py
            ├── admin.py
            ├── apps.py
            ├── migrations
            │   ├── 0001_initial.py
            │   └── __init__.py
            ├── models.py
            ├── serializers.py
            ├── temp.py
            ├── tests.py
            ├── urls.py
            ├── utils.py
            └── views.py
        ├── blogposts
            ├── __init__.py
            ├── admin.py
            ├── apps.py
            ├── migrations
            │   ├── 0001_initial.py
            │   └── __init__.py
            ├── models.py
            ├── serializers.py
            ├── tests.py
            ├── urls.py
            └── views.py
        ├── build.sh
        ├── chat
            ├── __init__.py
            ├── admin.py
            ├── apps.py
            ├── consumers.py
            ├── migrations
            │   ├── 0001_initial.py
            │   └── __init__.py
            ├── models.py
            ├── routing.py
            ├── serializers.py
            ├── tests.py
            ├── urls.py
            └── views.py
        ├── manage.py
        ├── project
            ├── __init__.py
            ├── asgi.py
            ├── middleware.py
            ├── settings.py
            ├── static
            │   ├── css
            │   │   └── style.css
            │   └── js
            │   │   ├── jquery-3.7.1.min.js
            │   │   └── plugin.js
            ├── urls.py
            └── wsgi.py
        ├── requirements.txt
        └── userprojects
            ├── __init__.py
            ├── admin.py
            ├── apps.py
            ├── migrations
                ├── 0001_initial.py
                └── __init__.py
            ├── models.py
            ├── serializers.py
            ├── tests.py
            ├── urls.py
            └── views.py
```

Wiki pages you might want to explore:
- [Command Line Interface (MoNafea01/AI-NO)](/wiki/MoNafea01/AI-NO#4.2)
- [Custom Data Formats and Testing (MoNafea01/AI-NO)](/wiki/MoNafea01/AI-NO#6.3)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/MoNafea01/AI-NO)
