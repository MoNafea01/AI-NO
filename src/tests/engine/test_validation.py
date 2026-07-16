"""Tests for app.engine.validation — all VALIDATION_REGISTRY validators."""

from app.engine.validation import validate_params


class TestValidateParams:
    def test_unknown_node_type(self):
        errors = validate_params("nonexistent_type", {})
        assert len(errors) == 1
        assert "No validator" in errors[0]


class TestValidateModel:
    def test_valid_model(self):
        data = {
            "model_type": "linear_models",
            "task": "regression",
            "model_name": "ridge",
        }
        errors = validate_params("create_model", data)
        assert errors == []

    def test_unknown_model_type(self):
        data = {"model_type": "unknown", "task": "t", "model_name": "n"}
        errors = validate_params("create_model", data)
        assert len(errors) == 1
        assert "Unknown model_type" in errors[0]

    def test_unknown_task(self):
        data = {"model_type": "linear_models", "task": "unknown", "model_name": "n"}
        errors = validate_params("create_model", data)
        assert len(errors) == 1
        assert "Unknown task" in errors[0]

    def test_unknown_name(self):
        data = {"model_type": "linear_models", "task": "regression", "model_name": "unknown"}
        errors = validate_params("create_model", data)
        assert len(errors) == 1
        assert "Unknown model_name" in errors[0]

    def test_all_unknown(self):
        data = {"model_type": "unknown", "task": "unknown", "model_name": "unknown"}
        errors = validate_params("create_model", data)
        assert len(errors) == 3


class TestValidatePreprocessor:
    def test_valid_preprocessor(self):
        data = {
            "preprocessor_type": "scaler",
            "preprocessor_name": "standard_scaler",
        }
        errors = validate_params("create_preprocessor", data)
        assert errors == []

    def test_unknown_type(self):
        data = {"preprocessor_type": "unknown", "preprocessor_name": "n"}
        errors = validate_params("create_preprocessor", data)
        assert any("Unknown preprocessor_type" in e for e in errors)

    def test_unknown_name(self):
        data = {
            "preprocessor_type": "scaler",
            "preprocessor_name": "unknown_scaler",
        }
        errors = validate_params("create_preprocessor", data)
        assert any("Unknown preprocessor_name" in e for e in errors)


class TestValidateDataLoader:
    def test_valid_with_dataset_name(self):
        errors = validate_params("data_loader", {"dataset_name": "iris"})
        assert errors == []

    def test_valid_with_dataset_path(self):
        errors = validate_params("data_loader", {"dataset_path": "/path/to/data.csv"})
        assert errors == []

    def test_missing_both(self):
        errors = validate_params("data_loader", {})
        assert len(errors) == 1


class TestValidateNoOp:
    """Validators that currently return no errors (action/utility nodes)."""

    def test_train_test_split(self):
        assert validate_params("train_test_split", {}) == []

    def test_splitter(self):
        assert validate_params("splitter", {}) == []

    def test_joiner(self):
        assert validate_params("joiner", {}) == []

    def test_fit_model(self):
        assert validate_params("fit_model", {}) == []

    def test_predict(self):
        assert validate_params("predict", {}) == []

    def test_evaluate(self):
        assert validate_params("evaluate", {}) == []

    def test_fit_preprocessor(self):
        assert validate_params("fit_preprocessor", {}) == []

    def test_transform(self):
        assert validate_params("transform", {}) == []

    def test_fit_transform(self):
        assert validate_params("fit_transform", {}) == []

    def test_input_layer(self):
        assert validate_params("create_input", {}) == []

    def test_dense(self):
        assert validate_params("dense", {}) == []

    def test_conv2d(self):
        assert validate_params("conv2d", {}) == []

    def test_maxpool2d(self):
        assert validate_params("maxpool2d", {}) == []

    def test_flatten(self):
        assert validate_params("flatten", {}) == []

    def test_dropout(self):
        assert validate_params("dropout", {}) == []

    def test_compile(self):
        assert validate_params("compile", {}) == []

    def test_fit_net(self):
        assert validate_params("fit_net", {}) == []

    def test_sequential(self):
        assert validate_params("sequential", {}) == []

    def test_save_template(self):
        assert validate_params("save_template", {}) == []

    def test_load_template(self):
        assert validate_params("load_template", {}) == []
