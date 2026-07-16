"""Tests for app.engine.result — Ok/Err Result type."""

from app.engine.exceptions import DataLoadError, EngineError
from app.engine.result import Err, Ok, fail, ok


class TestOk:
    def test_is_truthy(self):
        assert ok(42)

    def test_value(self):
        assert ok(42).value == 42

    def test_none_value(self):
        result = ok()
        assert result.value is None
        assert result  # still truthy

    def test_equality(self):
        assert ok(1) == Ok(1)

    def test_frozen(self):
        result = ok(10)
        try:
            result.value = 20
            assert False, "Should be frozen"
        except AttributeError:
            pass


class TestErr:
    def test_is_falsy(self):
        assert not fail(DataLoadError, "boom")

    def test_error(self):
        result = fail(DataLoadError, "boom")
        assert isinstance(result.error, DataLoadError)
        assert str(result.error) == "boom"

    def test_wraps_exception_instance(self):
        exc = ValueError("test")
        result = Err(exc)
        assert result.error is exc

    def test_frozen(self):
        result = fail(DataLoadError, "x")
        try:
            result.error = ValueError("y")
            assert False, "Should be frozen"
        except AttributeError:
            pass


class TestOkErrInteraction:
    def test_ok_is_not_err(self):
        r = ok("data")
        assert isinstance(r, Ok)
        assert not isinstance(r, Err)

    def test_err_is_not_ok(self):
        r = fail(DataLoadError, "x")
        assert isinstance(r, Err)
        assert not isinstance(r, Ok)

    def test_fail_factory(self):
        r = fail(EngineError, "general error")
        assert not r
        assert isinstance(r.error, EngineError)
