"""API smoke test — verifies app boots and health endpoint works."""

from fastapi.testclient import TestClient


def get_client():
    from app.main import app

    return TestClient(app)


def test_health_endpoint():
    client = get_client()
    response = client.get("/api/v1/health")
    assert response.status_code == 200


def test_docs_available():
    client = get_client()
    response = client.get("/docs")
    assert response.status_code == 200


def test_openapi_available():
    client = get_client()
    response = client.get("/openapi.json")
    assert response.status_code == 200
