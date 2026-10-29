# DevOps Monitoring & Flask-PostgreSQL Application

A secure, production-ready containerized microservice architecture featuring a Flask backend, PostgreSQL 15 data persistence, automated health checks with retries, resource reporting, and compressed database backups with automated retention policies orchestrated via Docker Compose.

---

## 🏗️ Architectural Overview & Security Design

```text
[Host Machine]
       │
       ├── Ports: 5000 (Flask Web App only)
       │
 [Docker Engine (Bridge Network)]
       ├── web-1 (Flask + Gunicorn, Healthchecks, Restart Policy)
       │         │
       │         └── (Internal TCP over Bridge) ──► db-1 (PostgreSQL 15, Isolated, No Host Port)
       │                                                 │
       └── Automation Scripts (/scripts)                 └── Named Volume (postgres_data)
                 ├── check_health.sh (HTTP retry loop)
                 ├── resource_report.sh (Docker stats capture)
                 └── backup_db.sh (Compressed pg_dump + gzip + retention)