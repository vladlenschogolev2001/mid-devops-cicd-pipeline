# CI/CD Pipeline — Middle DevOps Project

Полноценный CI/CD пайплайн для веб-приложения уровня Middle DevOps.

## Что внутри

- **Python FastAPI** приложение с health-check и метриками
- **Multi-stage Dockerfile** (оптимизированный, non-root)
- **GitHub Actions** пайплайн:
  - Lint + Unit tests
  - Security scanning (Trivy + Bandit)
  - Build & push Docker image в GitHub Container Registry
  - Deploy в Kubernetes (staging)
- **Kubernetes манифесты** + **Helm chart**
- Автоматический rollback при падении health-check

## Стек

| Компонент       | Технология              |
|-----------------|-------------------------|
| App             | FastAPI + Uvicorn       |
| Container       | Docker (multi-stage)    |
| CI/CD           | GitHub Actions          |
| Registry        | GHCR                    |
| Orchestration   | Kubernetes + Helm       |
| Security        | Trivy, Bandit, non-root |

## Быстрый старт

### 1. Локальный запуск приложения

```bash
cd app
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### 2. Сборка Docker-образа

```bash
docker build -t mid-devops-app:local .
docker run -p 8000:8000 mid-devops-app:local
```

### 3. Запуск в Kubernetes (kind / minikube)

```bash
# Создать кластер
kind create cluster --name devops-demo

# Применить манифесты
kubectl apply -f k8s/

# Или через Helm
helm upgrade --install mid-app ./helm/app -n demo --create-namespace
```

### 4. GitHub Actions

1. Создай репозиторий на GitHub
2. Добавь секреты (если нужно):
   - `KUBE_CONFIG` (base64 от kubeconfig)
3. Запушь код — пайплайн запустится автоматически

## Структура

```
01-cicd-pipeline/
├── .github/workflows/ci-cd.yml
├── app/
│   ├── main.py
│   ├── requirements.txt
│   └── tests/
├── Dockerfile
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── helm/app/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── scripts/
    └── healthcheck.sh
```

## Что показывает этот проект (Middle level)

- Правильный multi-stage Docker build
- Non-root контейнер
- Полноценный CI с security gates
- Deploy в Kubernetes
- Helm как packaging tool
- Health checks + readiness/liveness probes
- Автоматический rollback стратегия

## Лицензия

MIT
