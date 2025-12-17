# Simple Task Manager - Twelve-Factor App Implementation

Program sederhana untuk mendemonstrasikan implementasi 6 prinsip dari Twelve-Factor App methodology.

## Prinsip yang Diimplementasikan

### 1. Codebase

- Satu codebase dilacak dalam version control (Git)
- Satu repository untuk seluruh aplikasi
- Multiple deploys dari codebase yang sama

**Implementasi:**

```bash
git init
git add .
git commit -m "Initial commit"
```

### 2. Dependencies

- Dependencies dideklarasikan secara eksplisit di `requirements.txt`
- Tidak ada implicit dependencies
- Isolasi menggunakan virtual environment

**Implementasi:**

- File: `requirements.txt`
- Dependencies: Flask, python-dotenv, gunicorn, requests

### 3. Config (Dev only)

- Konfigurasi disimpan di environment variables
- Tidak ada hardcoded config dalam kode
- Menggunakan `.env` file untuk development

**Implementasi:**

- File: `config.py` - Membaca dari environment
- File: `.env.example` - Template konfigurasi
- Environment variables: APP_NAME, APP_ENV, APP_PORT, LOG_LEVEL, MAX_WORKERS

### 4. Concurrency (Bonus Implementation)

- Aplikasi dibagi menjadi modular services
- Setiap service bisa di-scale independently
- Menggunakan process model (gunicorn workers)

**Implementasi:**

- `TaskService` - Mengelola tasks
- `NotificationService` - Mengelola notifications
- Modular monolith architecture yang bisa di-scale dengan gunicorn workers

### 5. Logs

- Logs di-treat sebagai event streams
- Output ke stdout (bukan file)
- Structured logging (JSON format)

**Implementasi:**

- File: `logger.py`
- Structured JSON logs dengan timestamp, level, message, dan extra fields
- Semua logs ke stdout untuk easy aggregation

### 6. Build, Release, Run

- Strict separation antara build, release, dan run stages
- Menggunakan Makefile untuk automation
- Artifact yang immutable

**Implementasi:**

- `make build` - Build stage: Install dependencies & create artifacts
- `make release` - Release stage: Package dengan config
- `make run` - Run stage: Execute application

## Cara Menjalankan

### Prerequisite

- Python 3.8+
- pip
- make (atau GNU Make untuk Windows)

### Setup Development

1. **Clone repository**

```bash
git clone <repository-url>
cd Tugas-13
```

2. **Install dependencies (Build Stage)**

```bash
make install
```

3. **Setup konfigurasi**

```bash
# Copy .env.example ke .env
copy .env.example .env

# Edit .env sesuai kebutuhan
notepad .env
```

4. **Build application**

```bash
make build
```

5. **Create release package**

```bash
make release
```

6. **Run application**

```bash
make run
```

Atau jalankan seluruh workflow:

```bash
make deploy
```

### Development Mode

```bash
make dev
```

### Production Mode (dengan Gunicorn)

```bash
make run-prod
```

## Struktur Project

```
Tugas-13/
├── app.py                      # Main application
├── config.py                   # Configuration management (Principle 3)
├── logger.py                   # Structured logging (Principle 5)
├── requirements.txt            # Dependencies declaration (Principle 2)
├── Makefile                    # Build, Release, Run (Principle 6)
├── .env.example               # Config template
├── .gitignore                 # Git ignore rules
├── README.md                  # Documentation
└── services/                  # Modular services (Principle 4)
    ├── __init__.py
    ├── task_service.py        # Task management service
    └── notification_service.py # Notification service
```

## Makefile Commands

| Command         | Description                             | Stage   |
| --------------- | --------------------------------------- | ------- |
| `make help`     | Show available commands                 | -       |
| `make install`  | Install dependencies                    | Build   |
| `make build`    | Build application artifacts             | Build   |
| `make release`  | Create release package                  | Release |
| `make run`      | Run application                         | Run     |
| `make dev`      | Run in development mode                 | Run     |
| `make run-prod` | Run with gunicorn                       | Run     |
| `make clean`    | Clean build artifacts                   | -       |
| `make deploy`   | Complete workflow (clean→build→release) | All     |

## API Endpoints

### Health Check

```bash
GET /health
```

### Tasks

```bash
# Get all tasks
GET /api/tasks

# Create task
POST /api/tasks
Content-Type: application/json
{
  "title": "Task Title",
  "description": "Task Description"
}

# Get specific task
GET /api/tasks/{id}

# Update task status
PUT /api/tasks/{id}
Content-Type: application/json
{
  "status": "completed"
}

# Delete task
DELETE /api/tasks/{id}
```

### Notifications

```bash
# Get all notifications
GET /api/notifications
```

## Testing

```bash
# Start application
make run

# In another terminal, test endpoints
make test

# Or manual testing
curl http://localhost:5000/health
curl -X POST http://localhost:5000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"My Task","description":"Test task"}'
```

## Logs Example

Aplikasi menghasilkan structured logs dalam format JSON:

```json
{
  "timestamp": "2025-12-17T10:30:45.123456",
  "level": "INFO",
  "message": "Task created",
  "app": "SimpleTaskManager",
  "env": "development",
  "extra": {
    "task_id": 1,
    "title": "My Task"
  }
}
```

## Build & Release Process

### Build Stage

```bash
make build
```

- Install dependencies dari requirements.txt
- Create build artifacts
- Generate build-info.txt dengan timestamp & commit hash

### Release Stage

```bash
make release
```

- Copy application files ke `release/` directory
- Include configuration (.env)
- Create immutable release package
- Generate RELEASE-INFO.txt

### Run Stage

```bash
make run
```

- Execute application dari release package
- Load configuration dari environment
- Start web server

## Concurrency Implementation

Aplikasi menggunakan modular architecture:

1. **TaskService** - Independen service untuk task management
2. **NotificationService** - Independen service untuk notifications
3. **Gunicorn Workers** - Multiple worker processes untuk concurrency

Scale dengan gunicorn:

```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## Release Files

Setelah menjalankan `make release`, directory `release/` berisi:

- Semua source code files
- requirements.txt
- .env configuration
- build-info.txt
- RELEASE-INFO.txt

Package ini ready untuk di-deploy.
