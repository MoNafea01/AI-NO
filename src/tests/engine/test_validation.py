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
        assert len(errors) == 1
        assert "Unknown preprocessor_type" in errors[0]

    def test_unknown_name(self):
        data = {
            "preprocessor_type": "scaler",
            "preprocessor_name": "unknown_scaler",
        }
        errors = validate_params("create_preprocessor", data)
        assert len(errors) == 1
        assert "Unknown preprocessor_name" in errors[0]


class TestValidateDataLoader:
    def test_valid(self):
        errors = validate_params("data_loader", {"params": {"dataset_name": "iris"}})
        assert errors == []

    def test_missing_params(self):
        errors = validate_params("data_loader", {})
        assert len(errors) == 1

    def test_empty_params(self):
        errors = validate_params("data_loader", {"params": {}})
        assert len(errors) == 1


class TestValidateTrainTestSplit:
    def test_valid(self):
        errors = validate_params("train_test_split", {"X": 123})
        assert errors == []

    def test_missing_x(self):
        errors = validate_params("train_test_split", {})
        assert len(errors) == 1


class TestValidateSplitter:
    def test_valid(self):
        errors = validate_params("splitter", {"data": 123})
        assert errors == []

    def test_missing_data(self):
        errors = validate_params("splitter", {})
        assert len(errors) == 1


class TestValidateJoiner:
    def test_valid(self):
        errors = validate_params("joiner", {"data_1": 1, "data_2": 2})
        assert errors == []

    def test_missing_data_1(self):
        errors = validate_params("joiner", {"data_2": 2})
        assert len(errors) == 1

    def test_missing_data_2(self):
        errors = validate_params("joiner", {"data_1": 1})
        assert len(errors) == 1


class TestValidateFitModel:
    def test_valid(self):
        data = {"X": 1, "y": 2, "model": 3}
        errors = validate_params("fit_model", data)
        assert errors == []

    def test_valid_with_model_path(self):
        data = {"X": 1, "y": 2, "model_path": "/path/to/model.pkl"}
        errors = validate_params("fit_model", data)
        assert errors == []

    def test_missing_x(self):
        errors = validate_params("fit_model", {"y": 1, "model": 2})
        assert len(errors) == 1

    def test_missing_y(self):
        errors = validate_params("fit_model", {"X": 1, "model": 2})
        assert len(errors) == 1

    def test_missing_model(self):
        errors = validate_params("fit_model", {"X": 1, "y": 2})
        assert len(errors) == 1


class TestValidatePredict:
    def test_valid(self):
        data = {"X": 1, "fitted_model": 2}
        errors = validate_params("predict", data)
        assert errors == []

    def test_missing_fitted_model(self):
        errors = validate_params("predict", {"X": 1})
        assert len(errors) == 1

    def test_missing_x(self):
        errors = validate_params("predict", {"fitted_model": 1})
        assert len(errors) == 1


class TestValidateEvaluate:
    def test_valid(self):
        errors = validate_params("evaluate", {"y_true": 1, "y_pred": 2})
        assert errors == []

    def test_missing_y_true(self):
        errors = validate_params("evaluate", {"y_pred": 1})
        assert len(errors) == 1

    def test_missing_y_pred(self):
        errors = validate_params("evaluate", {"y_true": 1})
        assert len(errors) == 1


class TestValidateFitPreprocessor:
    def test_valid(self):
        errors = validate_params("fit_preprocessor", {"data": 1, "preprocessor": 2})
        assert errors == []

    def test_missing_data(self):
        errors = validate_params("fit_preprocessor", {"preprocessor": 1})
        assert len(errors) == 1

    def test_missing_preprocessor(self):
        errors = validate_params("fit_preprocessor", {"data": 1})
        assert len(errors) == 1


class TestValidateTransform:
    def test_valid(self):
        errors = validate_params("transform", {"data": 1, "fitted_preprocessor": 2})
        assert errors == []

    def test_missing_data(self):
        errors = validate_params("transform", {"fitted_preprocessor": 1})
        assert len(errors) == 1


class TestValidateFitTransform:
    def test_valid(self):
        errors = validate_params("fit_transform", {"data": 1, "preprocessor": 2})
        assert errors == []

    def test_missing_data(self):
        errors = validate_params("fit_transform", {"preprocessor": 1})
        assert len(errors) == 1


class TestValidateInputLayer:
    def test_valid(self):
        errors = validate_params("create_input", {"shape": [10]})
        assert errors == []

    def test_missing_shape(self):
        errors = validate_params("create_input", {})
        assert len(errors) == 1


class TestValidateDense:
    def test_valid(self):
        errors = validate_params("dense", {"units": 64})
        assert errors == []

    def test_missing_units(self):
        errors = validate_params("dense", {})
        assert len(errors) == 1

    def test_zero_units(self):
        errors = validate_params("dense", {"units": 0})
        assert len(errors) == 1

    def test_negative_units(self):
        errors = validate_params("dense", {"units": -1})
        assert len(errors) == 1


class TestValidateConv2d:
    def test_valid(self):
        errors = validate_params("conv2d", {"filters": 32, "kernel_size": 3})
        assert errors == []

    def test_missing_filters(self):
        errors = validate_params("conv2d", {"kernel_size": 3})
        assert len(errors) == 1

    def test_missing_kernel_size(self):
        errors = validate_params("conv2d", {"filters": 32})
        assert len(errors) == 1


class TestValidateMaxPool2d:
    def test_valid(self):
        errors = validate_params("maxpool2d", {"pool_size": 2})
        assert errors == []

    def test_missing_pool_size(self):
        errors = validate_params("maxpool2d", {})
        assert len(errors) == 1


class TestValidateFlatten:
    def test_always_valid(self):
        errors = validate_params("flatten", {})
        assert errors == []


class TestValidateDropout:
    def test_valid(self):
        errors = validate_params("dropout", {"rate": 0.5})
        assert errors == []

    def test_zero_rate(self):
        errors = validate_params("dropout", {"rate": 0})
        assert errors == []

    def test_rate_too_high(self):
        errors = validate_params("dropout", {"rate": 1.0})
        assert len(errors) == 1

    def test_negative_rate(self):
        errors = validate_params("dropout", {"rate": -0.1})
        assert len(errors) == 1

    def test_missing_rate_defaults_to_zero(self):
        errors = validate_params("dropout", {})
        assert errors == []


class TestValidateCompile:
    def test_valid(self):
        errors = validate_params("compile", {"loss": "mse"})
        assert errors == []

    def test_missing_loss(self):
        errors = validate_params("compile", {})
        assert len(errors) == 1


class TestValidateFitNet:
    def test_valid(self):
        errors = validate_params("fit_net", {"X": 1, "y": 2})
        assert errors == []

    def test_missing_x(self):
        errors = validate_params("fit_net", {"y": 1})
        assert len(errors) == 1

    def test_missing_y(self):
        errors = validate_params("fit_net", {"X": 1})
        assert len(errors) == 1


class TestValidateSequentialAndTemplates:
    def test_sequential_always_valid(self):
        assert validate_params("sequential", {}) == []

    def test_save_template_always_valid(self):
        assert validate_params("save_template", {}) == []

    def test_load_template_always_valid(self):
        assert validate_params("load_template", {}) == []
