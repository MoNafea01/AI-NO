"""Tests for app.engine.exceptions — exception hierarchy."""

import pytest

from app.engine.exceptions import (
    ConfigurationError,
    DataLoadError,
    EngineError,
    EvaluationError,
    ModelFitError,
    NodeCreationError,
    NodeNotFoundError,
    PersistenceError,
    PredictionError,
    TemplateError,
    ValidationError,
)


class TestExceptionHierarchy:
    def test_all_inherit_from_engine_error(self):
        exceptions = [
            NodeCreationError,
            NodeNotFoundError,
            DataLoadError,
            ModelFitError,
            PredictionError,
            EvaluationError,
            TemplateError,
            ValidationError,
            PersistenceError,
            ConfigurationError,
        ]
        for exc_cls in exceptions:
            assert issubclass(exc_cls, EngineError)

    def test_engine_error_is_base_exception(self):
        assert issubclass(EngineError, Exception)


class TestValidationError:
    def test_stores_errors_list(self):
        errors = ["missing field", "invalid type"]
        exc = ValidationError(errors)
        assert exc.errors == errors
        assert "missing field" in str(exc)

    def test_joins_errors_in_message(self):
        exc = ValidationError(["err1", "err2", "err3"])
        assert "err1" in str(exc)
        assert "err2" in str(exc)
        assert "err3" in str(exc)
        assert ";" in str(exc)


class TestExceptionRaise:
    def test_raise_engine_error(self):
        with pytest.raises(EngineError):
            raise EngineError("base error")

    def test_raise_node_creation_error(self):
        with pytest.raises(NodeCreationError):
            raise NodeCreationError("node failed")

    def test_raise_data_load_error(self):
        with pytest.raises(DataLoadError):
            raise DataLoadError("file not found")

    def test_raise_model_fit_error(self):
        with pytest.raises(ModelFitError):
            raise ModelFitError("fit failed")

    def test_catch_engine_error_catches_subclass(self):
        with pytest.raises(EngineError):
            raise NodeCreationError("child")
