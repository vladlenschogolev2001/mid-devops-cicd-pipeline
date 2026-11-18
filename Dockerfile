# ============ BUILD STAGE ============
FROM python:3.12-slim AS builder

WORKDIR /app

# Устанавливаем зависимости сборки
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY app/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt


# ============ RUNTIME STAGE ============
FROM python:3.12-slim AS runtime

# Создаём non-root пользователя
RUN groupadd -r appuser && useradd -r -g appuser -u 1001 appuser

WORKDIR /app

# Копируем только необходимые зависимости
COPY --from=builder /root/.local /home/appuser/.local
COPY app/ .

# Права
RUN chown -R appuser:appuser /app

ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV APP_ENV=production

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
