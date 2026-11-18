from fastapi import FastAPI, Response
from fastapi.responses import JSONResponse
import time
import os
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(
    title="Mid-DevOps Demo App",
    description="Sample application for CI/CD pipeline demonstration",
    version="1.0.0"
)

# Metrics
REQUEST_COUNT = Counter("http_requests_total", "Total HTTP requests", ["method", "endpoint", "status"])
REQUEST_LATENCY = Histogram("http_request_duration_seconds", "HTTP request latency", ["endpoint"])

START_TIME = time.time()


@app.middleware("http")
async def metrics_middleware(request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(endpoint=request.url.path).observe(duration)

    return response


@app.get("/")
async def root():
    return {
        "message": "Hello from Mid-DevOps CI/CD Pipeline!",
        "version": "1.0.0",
        "environment": os.getenv("APP_ENV", "local")
    }


@app.get("/health")
async def health():
    return {"status": "healthy", "uptime_seconds": round(time.time() - START_TIME, 2)}


@app.get("/ready")
async def ready():
    # Здесь можно добавить проверки зависимостей (БД, кэш и т.д.)
    return {"status": "ready"}


@app.get("/metrics")
async def metrics():
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/api/v1/info")
async def info():
    return {
        "app": "mid-devops-demo",
        "python_version": os.sys.version,
        "env": os.getenv("APP_ENV", "local"),
        "hostname": os.getenv("HOSTNAME", "unknown")
    }
