import multiprocessing
import os

bind = "0.0.0.0:8000"
workers = int(os.environ.get("GUNICORN_WORKERS", 2))
threads = int(os.environ.get("GUNICORN_THREADS", 2))
worker_class = "gthread"
timeout = int(os.environ.get("GUNICORN_TIMEOUT", 120))
keepalive = 5

accesslog = "-"
errorlog = "-"
loglevel = os.environ.get("GUNICORN_LOG_LEVEL", "info")

# Worker recycling to mitigate potential memory leaks
max_requests = 1000
max_requests_jitter = 50
