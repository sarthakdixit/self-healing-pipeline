import pytest
from fastapi.testclient import TestClient

from app.main import app, tasks

client = TestClient(app)


@pytest.fixture(autouse=True)
def reset_tasks():
    """Reset in-memory task store before each test."""
    tasks.clear()
    import app.main as main_module
    main_module.counter = 0
    yield
    tasks.clear()
    main_module.counter = 0


# ── Health Check ──────────────────────────────────────────────────────────────

def test_health_check():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "version": "1.0.0"}


# ── GET /tasks ─────────────────────────────────────────────────────────────────

def test_get_tasks_empty():
    response = client.get("/tasks")
    assert response.status_code == 200
    assert response.json() == []


def test_get_tasks_after_creation():
    client.post("/tasks", json={"title": "Test Task"})
    response = client.get("/tasks")
    assert response.status_code == 200
    assert len(response.json()) == 1


# ── POST /tasks ────────────────────────────────────────────────────────────────

def test_create_task():
    response = client.post("/tasks", json={"title": "Buy groceries", "description": "Milk and eggs"})
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Buy groceries"
    assert data["description"] == "Milk and eggs"
    assert data["completed"] is False
    assert data["id"] == 1


def test_create_task_without_description():
    response = client.post("/tasks", json={"title": "Simple task"})
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Simple task"
    assert data["description"] is None


def test_create_task_missing_title():
    response = client.post("/tasks", json={"description": "No title provided"})
    assert response.status_code == 422


def test_create_task_empty_title():
    response = client.post("/tasks", json={"title": ""})
    assert response.status_code == 422


# ── PUT /tasks/{id} ────────────────────────────────────────────────────────────

def test_complete_task():
    client.post("/tasks", json={"title": "Finish report"})
    response = client.put("/tasks/1", json={"completed": True})
    assert response.status_code == 200
    assert response.json()["completed"] is True


def test_uncomplete_task():
    client.post("/tasks", json={"title": "Finish report"})
    client.put("/tasks/1", json={"completed": True})
    response = client.put("/tasks/1", json={"completed": False})
    assert response.status_code == 200
    assert response.json()["completed"] is False


def test_update_nonexistent_task():
    response = client.put("/tasks/999", json={"completed": True})
    assert response.status_code == 404
    assert "not found" in response.json()["detail"]


# ── DELETE /tasks/{id} ─────────────────────────────────────────────────────────

def test_delete_task():
    client.post("/tasks", json={"title": "Task to delete"})
    response = client.delete("/tasks/1")
    assert response.status_code == 200
    assert "deleted successfully" in response.json()["message"]


def test_delete_task_removes_from_list():
    client.post("/tasks", json={"title": "Task to delete"})
    client.delete("/tasks/1")
    response = client.get("/tasks")
    assert response.json() == []


def test_delete_nonexistent_task():
    response = client.delete("/tasks/999")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"]
