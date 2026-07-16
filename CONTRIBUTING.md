# Contributing to AI-NO

Thank you for your interest in contributing to AI-NO! This guide will help you get started.

## Development Setup

### Prerequisites

- Python 3.10+
- PostgreSQL
- Redis
- [uv](https://docs.astral.sh/uv/) (recommended) or pip

### Getting Started

```bash
# Clone the repository
git clone https://github.com/MoNafea01/AI-NO.git
cd AI-NO

# Install dependencies
cd src
uv sync --all-extras
# or: pip install -e ".[dev]"

# Set up environment variables
cp .env.example .env
# Edit .env with your database and Redis credentials

# Apply database migrations
alembic upgrade head

# Start the dev server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# In a separate terminal, start the Celery worker
celery -A app.celery_app worker --loglevel=info
```

### Running with Docker

```bash
docker compose up -d
```

## Code Style

We use [Ruff](https://docs.astral.sh/ruff/) for linting and formatting.

```bash
# Check for issues
ruff check src/app/engine

# Auto-fix issues
ruff check --fix src/app/engine

# Format code
ruff format src/app
```

### Key Conventions

- **Engine classes** are synchronous, wrapped in `asyncio.to_thread()` for async endpoints
- **Two-phase repository pattern**: async repos for API layer, sync repos for Celery workers
- **Port-based connections**: `in_ports`/`out_ports` are `dict[str, str]` keyed by port name
- **Node PK** is single-column `id` (BigInteger, uuid-based)
- **No comments** unless explicitly requested
- **`components.json`** is the source of truth for port names and component definitions

## Project Structure

```
src/app/
  api/           # FastAPI route handlers
  core/          # Auth, config, middleware
  engine/        # Node execution engine
  db/sql/        # SQLAlchemy models + Alembic migrations
  services/      # Business logic services
  tasks/         # Celery task definitions
```

## Submitting Changes

1. Create a feature branch from `new_architecture`:
   ```bash
   git checkout -b feature/your-feature
   ```

2. Make your changes and ensure lint passes:
   ```bash
   ruff check src/app
   ```

3. Commit with a descriptive message following [Conventional Commits](https://www.conventionalcommits.org/):
   ```
   feat: add new data loader node type
   fix: resolve port resolution in action nodes
   docs: update README with setup instructions
   ```

4. Push and open a Pull Request against `new_architecture`.

## Pull Request Guidelines

- Keep PRs focused on a single change
- Include a clear description of what changed and why
- Ensure all existing tests pass
- Add tests for new functionality when possible
- Update documentation if your change affects the public API

## Reporting Issues

- Use the [GitHub Issues](https://github.com/MoNafea01/AI-NO/issues) tracker
- Include steps to reproduce for bug reports
- Check existing issues before creating new ones

## Questions?

Open a [Discussion](https://github.com/MoNafea01/AI-NO/discussions) for general questions and ideas.
