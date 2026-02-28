from typing import List

from fastapi import FastAPI, HTTPException

from app.models import Task, TaskCreate, TaskUpdate

app = FastAPI(
    title="Task Manager API",
    description="A simple Task Manager API — part of the Self-Healing CI/CD Pipeline portfolio project.",
    version="1.0.0",
)

# In-memory task store
tasks: List[Task] = []
counter: int = 0


@app.get("/", tags=["Health"])
def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "version": "1.0.0"}


@app.get("/tasks", response_model=List[Task], tags=["Tasks"])
def get_tasks():
    """Return all tasks."""
    return tasks


@app.post("/tasks", response_model=Task, status_code=201, tags=["Tasks"])
def create_task(task_data: TaskCreate):
    """Create a new task."""
    global counter
    counter += 1
    new_task = Task(
        id=counter,
        title=task_data.title,
        description=task_data.description,
        completed=False,
    )
    tasks.append(new_task)
    return new_task


@app.put("/tasks/{task_id}", response_model=Task, tags=["Tasks"])
def update_task(task_id: int, update: TaskUpdate):
    """Mark a task as complete or incomplete."""
    for task in tasks:
        if task.id == task_id:
            task.completed = update.completed
            return task
    raise HTTPException(status_code=404, detail=f"Task with id {task_id} not found")


@app.delete("/tasks/{task_id}", tags=["Tasks"])
def delete_task(task_id: int):
    """Delete a task by ID."""
    for index, task in enumerate(tasks):
        if task.id == task_id:
            tasks.pop(index)
            return {"message": f"Task {task_id} deleted successfully"}
    raise HTTPException(status_code=404, detail=f"Task with id {task_id} not found")
