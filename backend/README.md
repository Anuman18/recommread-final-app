# AI Career & Learning OS Backend

A modular, clean, and database-backed FastAPI engine powering the AI Career & Learning OS application.

## Core Technologies
* **FastAPI**: Core REST API framework
* **PostgreSQL**: Relational database storage
* **SQLAlchemy**: ORM models mapping
* **JWT Authentication**: User security session credentials
* **Pydantic**: Data validation and response schemas

---

## Directory Structure

```
backend/
  app/
    core/             # Config, db engine, JWT security, seeder
    models/           # SQLAlchemy models mapped to tables
    schemas/          # Pydantic schemas validating input/outputs
    api/              # FastAPI router paths
      endpoints/      # Feature endpoints (auth, projects, interviews, coding)
    main.py           # App entrypoint initializing lifespan hooks
    create_db.py      # Script to create all tables and run seed data
  requirements.txt    # Package dependencies
  venv/               # Isolated virtual environment
```

---

## Getting Started

### 1. Prerequisites
Ensure you have Python 3.10+ installed and a local PostgreSQL instance running.

The PostgreSQL database must be named `career_os`. If it doesn't exist, create it:
```bash
createdb career_os
```

### 2. Startup Database & Tables Setup
Initialize the database schemas and mock records:
```bash
venv/bin/python3 -m app.create_db
```

### 3. Running the Server
Run the FastAPI development server:
```bash
venv/bin/uvicorn app.main:app --reload
```
The server will start on `http://127.0.0.1:8000`. You can access the interactive API docs at `http://127.0.0.1:8000/docs`.
