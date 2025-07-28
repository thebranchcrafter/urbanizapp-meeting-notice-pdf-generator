# Makefile para Meeting Notice PDF Generator API
# Variables
PYTHON = python3
PIP = pip3
VENV = venv
VENV_PYTHON = $(VENV)/bin/python
VENV_PIP = $(VENV)/bin/pip
APP_NAME = pdf-generator-api
DOCKER_IMAGE = $(APP_NAME)
DOCKER_TAG = latest
PORT = 8000
PYTHONPATH = $(PWD)

# Colores para output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help install install-dev run run-dev test clean docker-build docker-run docker-stop docker-clean docker-push lint format check test-api build-cli

# Comando por defecto
.DEFAULT_GOAL := help

help: ## Mostrar esta ayuda
	@echo "$(GREEN)Meeting Notice PDF Generator API$(NC)"
	@echo "Comandos disponibles:"
	@echo ""
	@echo "$(GREEN)🚀 DESARROLLO RÁPIDO:$(NC)"
	@echo "  $(YELLOW)start$(NC)           Iniciar desarrollo con Docker (recomendado)"
	@echo "  $(YELLOW)dev$(NC)             Ejecutar en modo desarrollo local"
	@echo "  $(YELLOW)test-api$(NC)        Probar la API"
	@echo ""
	@echo "$(GREEN)🐳 DOCKER:$(NC)"
	@echo "  $(YELLOW)docker-compose-dev$(NC)      Desarrollo con Docker Compose"
	@echo "  $(YELLOW)docker-compose-dev-hot$(NC)  Desarrollo con hot reload optimizado"
	@echo "  $(YELLOW)docker-dev$(NC)              Desarrollo con Docker directo"
	@echo "  $(YELLOW)docker-logs$(NC)             Ver logs del contenedor"
	@echo "  $(YELLOW)docker-stop$(NC)             Detener contenedor"
	@echo ""
	@echo "$(GREEN)🔧 DESARROLLO:$(NC)"
	@echo "  $(YELLOW)format$(NC)          Formatear código"
	@echo "  $(YELLOW)lint$(NC)             Ejecutar linter"
	@echo "  $(YELLOW)test$(NC)             Ejecutar tests"
	@echo "  $(YELLOW)clean$(NC)            Limpiar archivos temporales"
	@echo ""
	@echo "$(GREEN)📊 UTILIDADES:$(NC)"
	@echo "  $(YELLOW)status$(NC)           Verificar estado de la app"
	@echo "  $(YELLOW)open-docs$(NC)        Abrir documentación"
	@echo "  $(YELLOW)info$(NC)             Información del sistema"
	@echo ""
	@echo "$(GREEN)📦 EJECUTABLE CLI:$(NC)"
	@echo "  $(YELLOW)build-cli$(NC)        Generar ejecutable del CLI"
	@echo "  $(YELLOW)build-cli-docker$(NC) Generar ejecutable con Docker (evita sandbox)"
	@echo "  $(YELLOW)build-cli-docker-simple$(NC) Generar ejecutable con Docker (versión simple)"
	@echo "  $(YELLOW)build-cli-docker-ubuntu$(NC) Generar ejecutable con Docker Ubuntu (compatible)"
	@echo "  $(YELLOW)build-cli-x86_64$(NC) Generar ejecutable para x86_64 Ubuntu (sistema host)"
	@echo "  $(YELLOW)build-cli-arm64$(NC) Generar ejecutable para Linux ARM64"
	@echo "  $(YELLOW)build-apps$(NC) Generar ejecutables para x86_64 y ARM64 (en paralelo)"
	@echo "  $(YELLOW)build-apps-j4$(NC) Generar ejecutables con 4 jobs en paralelo"
	@echo "  $(YELLOW)build-apps-auto$(NC) Generar ejecutables con jobs automáticos (detecta CPUs)"
	@echo "  $(YELLOW)test-cli$(NC)         Probar el CLI con datos de ejemplo"
	@echo ""
	@echo "$(GREEN)📋 TODOS LOS COMANDOS:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

venv: ## Crear entorno virtual
	@echo "$(GREEN)Creando entorno virtual...$(NC)"
	$(PYTHON) -m venv $(VENV)
	@echo "$(GREEN)Entorno virtual creado. Actívalo con: source $(VENV)/bin/activate$(NC)"

install: venv ## Instalar dependencias de producción
	@echo "$(GREEN)Instalando dependencias de producción...$(NC)"
	$(VENV_PIP) install -r requirements.txt

install-dev: venv ## Instalar dependencias de desarrollo
	@echo "$(GREEN)Instalando dependencias de desarrollo...$(NC)"
	$(VENV_PIP) install -r requirements.txt
	$(VENV_PIP) install black isort pytest pytest-asyncio requests

run: ## Ejecutar la aplicación en modo producción
	@echo "$(GREEN)Ejecutando aplicación en modo producción...$(NC)"
	PYTHONPATH=$(PYTHONPATH) $(VENV_PYTHON) -m app.main

run-dev: ## Ejecutar la aplicación en modo desarrollo con reload
	@echo "$(GREEN)Ejecutando aplicación en modo desarrollo...$(NC)"
	PYTHONPATH=$(PYTHONPATH) $(VENV_PYTHON) -m uvicorn app.main:app --host 0.0.0.0 --port $(PORT) --reload

test: ## Ejecutar tests
	@echo "$(GREEN)Ejecutando tests...$(NC)"
	PYTHONPATH=$(PYTHONPATH) $(VENV_PYTHON) -m pytest -v

test-api: ## Probar la API con el script de ejemplo
	@echo "$(GREEN)Probando la API...$(NC)"
	@if ! pgrep -f "uvicorn.*app.main:app" > /dev/null; then \
		echo "$(YELLOW)La API no está ejecutándose. Iniciando en segundo plano...$(NC)"; \
		$(MAKE) run-dev & \
		sleep 5; \
	fi
	$(VENV_PYTHON) test_example.py

lint: ## Ejecutar linter (flake8)
	@echo "$(GREEN)Ejecutando linter...$(NC)"
	@if [ -f "$(VENV)/bin/flake8" ]; then \
		$(VENV)/bin/flake8 app/ --max-line-length=88 --ignore=E203,W503; \
	else \
		echo "$(YELLOW)flake8 no está instalado. Instalando...$(NC)"; \
		$(VENV_PIP) install flake8; \
		$(VENV)/bin/flake8 app/ --max-line-length=88 --ignore=E203,W503; \
	fi

format: ## Formatear código con black e isort
	@echo "$(GREEN)Formateando código...$(NC)"
	@if [ -f "$(VENV)/bin/black" ]; then \
		$(VENV)/bin/black app/; \
	else \
		echo "$(YELLOW)black no está instalado. Instalando...$(NC)"; \
		$(VENV_PIP) install black; \
		$(VENV)/bin/black app/; \
	fi
	@if [ -f "$(VENV)/bin/isort" ]; then \
		$(VENV)/bin/isort app/; \
	else \
		echo "$(YELLOW)isort no está instalado. Instalando...$(NC)"; \
		$(VENV_PIP) install isort; \
		$(VENV)/bin/isort app/; \
	fi

check: ## Verificar formato del código
	@echo "$(GREEN)Verificando formato del código...$(NC)"
	@if [ -f "$(VENV)/bin/black" ]; then \
		$(VENV)/bin/black --check app/; \
	else \
		echo "$(YELLOW)black no está instalado. Instalando...$(NC)"; \
		$(VENV_PIP) install black; \
		$(VENV)/bin/black --check app/; \
	fi
	@if [ -f "$(VENV)/bin/isort" ]; then \
		$(VENV)/bin/isort --check-only app/; \
	else \
		echo "$(YELLOW)isort no está instalado. Instalando...$(NC)"; \
		$(VENV_PIP) install isort; \
		$(VENV)/bin/isort --check-only app/; \
	fi

clean: ## Limpiar archivos temporales y cache
	@echo "$(GREEN)Limpiando archivos temporales...$(NC)"
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".coverage" -delete
	find . -name "*.pdf" -type f -delete
	@echo "$(GREEN)Limpieza completada$(NC)"

clean-venv: ## Limpiar entorno virtual
	@echo "$(GREEN)Limpiando entorno virtual...$(NC)"
	rm -rf $(VENV)
	@echo "$(GREEN)Entorno virtual eliminado$(NC)"

clean-all: clean clean-venv ## Limpiar todo (archivos temporales + entorno virtual)
	@echo "$(GREEN)Limpieza completa realizada$(NC)"

# Docker commands
docker-build: ## Construir imagen Docker
	@echo "$(GREEN)Construyendo imagen Docker...$(NC)"
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker-run: ## Ejecutar contenedor Docker
	@echo "$(GREEN)Ejecutando contenedor Docker...$(NC)"
	docker run -d --name $(APP_NAME) -p $(PORT):$(PORT) $(DOCKER_IMAGE):$(DOCKER_TAG)

docker-stop: ## Detener contenedor Docker
	@echo "$(GREEN)Deteniendo contenedor Docker...$(NC)"
	@docker stop $(APP_NAME) 2>/dev/null || echo "$(YELLOW)Contenedor no está ejecutándose$(NC)"

docker-clean: ## Limpiar contenedores e imágenes Docker
	@echo "$(GREEN)Limpiando Docker...$(NC)"
	@docker stop $(APP_NAME) 2>/dev/null || true
	@docker rm $(APP_NAME) 2>/dev/null || true
	@docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG) 2>/dev/null || true

docker-compose-up: ## Ejecutar con Docker Compose
	@echo "$(GREEN)Ejecutando con Docker Compose...$(NC)"
	docker-compose up --build

docker-compose-down: ## Detener Docker Compose
	@echo "$(GREEN)Deteniendo Docker Compose...$(NC)"
	docker-compose down

docker-compose-logs: ## Ver logs de Docker Compose
	@echo "$(GREEN)Mostrando logs de Docker Compose...$(NC)"
	docker-compose logs -f

docker-compose-dev-logs: ## Ver logs del desarrollo con hot reload
	@echo "$(GREEN)Mostrando logs del desarrollo con hot reload...$(NC)"
	docker-compose -f docker-compose.dev.yml logs -f

docker-compose-dev-down: ## Detener desarrollo con hot reload
	@echo "$(GREEN)Deteniendo desarrollo con hot reload...$(NC)"
	docker-compose -f docker-compose.dev.yml down

docker-compose-dev: ## Desarrollo local con Docker Compose (recomendado)
	@echo "$(GREEN)🚀 Iniciando desarrollo local con Docker Compose...$(NC)"
	@echo "$(YELLOW)📦 Construyendo y ejecutando contenedores...$(NC)"
	@docker-compose up --build -d
	@echo "$(GREEN)✅ Aplicación iniciada en segundo plano$(NC)"
	@echo "$(YELLOW)📊 Esperando que la aplicación esté lista...$(NC)"
	@sleep 5
	@echo "$(GREEN)🌐 Aplicación disponible en: http://localhost:$(PORT)$(NC)"
	@echo "$(GREEN)📚 Documentación: http://localhost:$(PORT)/docs$(NC)"
	@echo "$(GREEN)🏥 Health check: http://localhost:$(PORT)/health$(NC)"
	@echo "$(YELLOW)📋 Para ver logs: make docker-compose-logs$(NC)"
	@echo "$(YELLOW)🛑 Para detener: make docker-compose-down$(NC)"
	@echo "$(YELLOW)🧪 Para probar: make test-api$(NC)"

docker-compose-dev-hot: ## Desarrollo con hot reload optimizado
	@echo "$(GREEN)🔥 Iniciando desarrollo con hot reload optimizado...$(NC)"
	@echo "$(YELLOW)📦 Construyendo y ejecutando contenedores con volúmenes optimizados...$(NC)"
	@docker-compose -f docker-compose.dev.yml up --build -d
	@echo "$(GREEN)✅ Aplicación iniciada con hot reload$(NC)"
	@echo "$(YELLOW)📊 Esperando que la aplicación esté lista...$(NC)"
	@sleep 3
	@echo "$(GREEN)🌐 Aplicación disponible en: http://localhost:$(PORT)$(NC)"
	@echo "$(GREEN)📚 Documentación: http://localhost:$(PORT)/docs$(NC)"
	@echo "$(GREEN)🏥 Health check: http://localhost:$(PORT)/health$(NC)"
	@echo "$(GREEN)🔄 Hot reload activado - los cambios se reflejarán automáticamente$(NC)"
	@echo "$(YELLOW)📋 Para ver logs: make docker-compose-dev-logs$(NC)"
	@echo "$(YELLOW)🛑 Para detener: make docker-compose-dev-down$(NC)"
	@echo "$(YELLOW)🧪 Para probar: make test-api$(NC)"

docker-compose-fast: ## Desarrollo local con Docker Compose (versión rápida Alpine)
	@echo "$(GREEN)🚀 Iniciando desarrollo local con Docker Compose (Alpine)...$(NC)"
	@echo "$(YELLOW)📦 Construyendo y ejecutando contenedores...$(NC)"
	@docker-compose -f docker-compose.yml up --build -d
	@echo "$(GREEN)✅ Aplicación iniciada en segundo plano$(NC)"
	@echo "$(YELLOW)📊 Esperando que la aplicación esté lista...$(NC)"
	@sleep 3
	@echo "$(GREEN)🌐 Aplicación disponible en: http://localhost:$(PORT)$(NC)"
	@echo "$(GREEN)📚 Documentación: http://localhost:$(PORT)/docs$(NC)"
	@echo "$(GREEN)🏥 Health check: http://localhost:$(PORT)/health$(NC)"
	@echo "$(YELLOW)📋 Para ver logs: make docker-compose-logs$(NC)"
	@echo "$(YELLOW)🛑 Para detener: make docker-compose-down$(NC)"
	@echo "$(YELLOW)🧪 Para probar: make test-api$(NC)"

# Desarrollo local con Docker
docker-dev: docker-clean docker-build docker-run ## Desarrollo local: build + run + logs
	@echo "$(GREEN)🚀 Aplicación iniciada en Docker para desarrollo local$(NC)"
	@echo "$(YELLOW)📊 Esperando que la aplicación esté lista...$(NC)"
	@sleep 3
	@echo "$(GREEN)✅ Aplicación disponible en: http://localhost:$(PORT)$(NC)"
	@echo "$(GREEN)📚 Documentación: http://localhost:$(PORT)/docs$(NC)"
	@echo "$(GREEN)🏥 Health check: http://localhost:$(PORT)/health$(NC)"
	@echo "$(YELLOW)📋 Para ver logs: make docker-logs$(NC)"
	@echo "$(YELLOW)🛑 Para detener: make docker-stop$(NC)"

docker-dev-detached: docker-clean docker-build ## Desarrollo local: build + run en segundo plano
	@echo "$(GREEN)Construyendo y ejecutando en segundo plano...$(NC)"
	@docker run -d --name $(APP_NAME) -p $(PORT):$(PORT) $(DOCKER_IMAGE):$(DOCKER_TAG)
	@echo "$(GREEN)✅ Aplicación ejecutándose en segundo plano$(NC)"
	@echo "$(GREEN)🌐 URL: http://localhost:$(PORT)$(NC)"
	@echo "$(YELLOW)📋 Para ver logs: make docker-logs$(NC)"
	@echo "$(YELLOW)🛑 Para detener: make docker-stop$(NC)"

docker-logs: ## Ver logs del contenedor Docker
	@echo "$(GREEN)Mostrando logs del contenedor...$(NC)"
	@if docker ps | grep -q $(APP_NAME); then \
		docker logs -f $(APP_NAME); \
	else \
		echo "$(RED)❌ El contenedor $(APP_NAME) no está ejecutándose$(NC)"; \
		echo "$(YELLOW)💡 Ejecuta: make docker-dev$(NC)"; \
	fi

docker-restart: docker-stop docker-run ## Reiniciar contenedor Docker
	@echo "$(GREEN)✅ Contenedor reiniciado$(NC)"
	@echo "$(GREEN)🌐 URL: http://localhost:$(PORT)$(NC)"

# Desarrollo
dev-setup: install-dev format ## Configurar entorno de desarrollo
	@echo "$(GREEN)Entorno de desarrollo configurado$(NC)"

dev: run-dev ## Alias para modo desarrollo

# Desarrollo con Docker (recomendado)
docker-setup: docker-compose-dev ## Configurar y ejecutar con Docker (recomendado)
	@echo "$(GREEN)🎉 ¡Desarrollo con Docker configurado y ejecutándose!$(NC)"

# Comando principal para desarrollo
start: docker-compose-dev-hot ## Iniciar desarrollo con hot reload (recomendado)
	@echo "$(GREEN)🎯 Desarrollo con hot reload iniciado con éxito$(NC)"

# Producción
prod-setup: install ## Configurar entorno de producción
	@echo "$(GREEN)Entorno de producción configurado$(NC)"

prod: run ## Alias para modo producción

# CI/CD
ci: install-dev lint check test ## Pipeline de CI
	@echo "$(GREEN)Pipeline de CI completado exitosamente$(NC)"

# Utilidades
logs: ## Ver logs de la aplicación (si está ejecutándose con Docker)
	@if docker ps | grep -q $(APP_NAME); then \
		docker logs -f $(APP_NAME); \
	else \
		echo "$(YELLOW)La aplicación no está ejecutándose en Docker$(NC)"; \
	fi

status: ## Verificar estado de la aplicación
	@echo "$(GREEN)Verificando estado de la aplicación...$(NC)"
	@if curl -s http://localhost:$(PORT)/health > /dev/null; then \
		echo "$(GREEN)✅ La aplicación está ejecutándose en http://localhost:$(PORT)$(NC)"; \
		curl -s http://localhost:$(PORT)/health | python3 -m json.tool; \
	else \
		echo "$(RED)❌ La aplicación no está ejecutándose$(NC)"; \
	fi

open-docs: ## Abrir documentación de la API en el navegador
	@echo "$(GREEN)Abriendo documentación de la API...$(NC)"
	@if command -v xdg-open > /dev/null; then \
		xdg-open http://localhost:$(PORT)/docs; \
	elif command -v open > /dev/null; then \
		open http://localhost:$(PORT)/docs; \
	else \
		echo "$(YELLOW)No se pudo abrir el navegador automáticamente$(NC)"; \
		echo "$(YELLOW)Abre manualmente: http://localhost:$(PORT)/docs$(NC)"; \
	fi

# Backup y restore
backup: ## Crear backup del código
	@echo "$(GREEN)Creando backup...$(NC)"
	@tar -czf backup_$(shell date +%Y%m%d_%H%M%S).tar.gz --exclude='.git' --exclude='__pycache__' --exclude='*.pyc' .

# Información del sistema
info: ## Mostrar información del sistema y dependencias
	@echo "$(GREEN)Información del sistema:$(NC)"
	@echo "Python: $(shell $(PYTHON) --version)"
	@echo "Pip: $(shell $(PIP) --version)"
	@echo "Docker: $(shell docker --version 2>/dev/null || echo 'No instalado')"
	@echo "Docker Compose: $(shell docker-compose --version 2>/dev/null || echo 'No instalado')"
	@echo "Directorio actual: $(PWD)"
	@echo "Puerto: $(PORT)"

# Comandos para generar ejecutable CLI
build-cli: ## Generar ejecutable del CLI usando PyInstaller
	@echo "$(GREEN)🔨 Generando ejecutable del CLI...$(NC)"
	@echo "$(YELLOW)Configurando variables de entorno para evitar problemas de sandbox...$(NC)"
	@export WEASYPRINT_NO_SANDBOX=1; \
	export CHROME_NO_SANDBOX=1; \
	if [ -f "$(VENV)/bin/python" ]; then \
		$(VENV_PYTHON) build_cli.py; \
	else \
		echo "$(YELLOW)Entorno virtual no encontrado. Creando...$(NC)"; \
		$(MAKE) install-dev; \
		$(VENV_PYTHON) build_cli.py; \
	fi

test-cli: ## Probar el CLI con datos de ejemplo
	@echo "$(GREEN)🧪 Probando el CLI...$(NC)"
	@if [ -f "dist/meeting-notice-pdf-generator" ]; then \
		echo "$(GREEN)✅ Ejecutable encontrado. Probando...$(NC)"; \
		./dist/meeting-notice-pdf-generator --json-file example_data.json --output test_output.pdf; \
		if [ -f "test_output.pdf" ]; then \
			echo "$(GREEN)✅ PDF generado exitosamente: test_output.pdf$(NC)"; \
			ls -la test_output.pdf; \
		else \
			echo "$(RED)❌ Error: No se generó el PDF$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)Ejecutable no encontrado. Generando...$(NC)"; \
		$(MAKE) build-cli; \
		$(MAKE) test-cli; \
	fi

clean-cli: ## Limpiar archivos del ejecutable CLI
	@echo "$(GREEN)🧹 Limpiando archivos del ejecutable CLI...$(NC)"
	rm -rf dist/
	rm -rf build/
	rm -f *.spec
	rm -f test_output.pdf
	@echo "$(GREEN)✅ Limpieza del CLI completada$(NC)"

clean-cli-x86_64: ## Limpiar solo ejecutable x86_64
	@echo "$(GREEN)🧹 Limpiando ejecutable x86_64...$(NC)"
	rm -rf dist/x86_64/
	rm -rf build/
	rm -f *.spec
	@echo "$(GREEN)✅ Limpieza del ejecutable x86_64 completada$(NC)"

clean-cli-arm64: ## Limpiar solo ejecutable ARM64
	@echo "$(GREEN)🧹 Limpiando ejecutable ARM64...$(NC)"
	rm -rf dist/aarch64/
	rm -rf build/
	rm -f *.spec
	@echo "$(GREEN)✅ Limpieza del ejecutable ARM64 completada$(NC)"

build-cli-docker: ## Generar ejecutable del CLI usando Docker (evita problemas de sandbox)
	@echo "$(GREEN)🐳 Generando ejecutable del CLI usando Docker...$(NC)"
	@echo "$(YELLOW)Esto evita problemas de sandbox en el sistema host$(NC)"
	./docker-build-cli.sh
	@echo "$(GREEN)✅ Ejecutable generado con Docker$(NC)"

build-cli-docker-simple: ## Generar ejecutable del CLI usando Docker (versión simple)
	@echo "$(GREEN)🐳 Generando ejecutable del CLI usando Docker (versión simple)...$(NC)"
	@echo "$(YELLOW)Usa docker run directamente sin Dockerfile$(NC)"
	./docker-build-cli-simple.sh
	@echo "$(GREEN)✅ Ejecutable generado con Docker (versión simple)$(NC)"

build-cli-docker-ubuntu: ## Generar ejecutable del CLI usando Docker Ubuntu (compatible con glibc)
	@echo "$(GREEN)🐳 Generando ejecutable del CLI usando Docker Ubuntu...$(NC)"
	@echo "$(YELLOW)Genera ejecutable compatible con sistemas glibc (Ubuntu/Debian)$(NC)"
	./docker-build-cli-ubuntu.sh
	@echo "$(GREEN)✅ Ejecutable generado con Docker Ubuntu$(NC)"

build-cli-x86_64: ## Generar ejecutable del CLI para x86_64 Ubuntu (sistema host)
	@echo "$(GREEN)🐳 Generando ejecutable del CLI para x86_64 Ubuntu...$(NC)"
	@echo "$(YELLOW)Genera ejecutable para el sistema host actual (x86_64 Ubuntu)$(NC)"
	./docker-build-cli-x86_64.sh
	@echo "$(GREEN)✅ Ejecutable x86_64 generado$(NC)"

build-cli-arm64: ## Generar ejecutable del CLI para Linux ARM64
	@echo "$(GREEN)🐳 Generando ejecutable del CLI para Linux ARM64...$(NC)"
	@echo "$(YELLOW)Genera ejecutable para sistemas Linux ARM64$(NC)"
	./docker-build-cli-arm64.sh
	@echo "$(GREEN)✅ Ejecutable ARM64 generado$(NC)"

build-apps: ## Generar ejecutables para x86_64 (host) y ARM64 (en paralelo)
	@echo "$(GREEN)🚀 Generando ejecutables para x86_64 y ARM64 en paralelo...$(NC)"
	@echo "$(YELLOW)Iniciando generación paralela...$(NC)"
	@$(MAKE) -j2 build-cli-x86_64 build-cli-arm64
	@echo "$(GREEN)✅ Ejecutables generados en dist/x86_64/ y dist/aarch64/$(NC)"
	@echo "$(GREEN)📁 Estructura final:$(NC)"
	@echo "$(GREEN)📋 Ejecutables disponibles:$(NC)"
	@if [ -f "dist/x86_64/meeting-notice-pdf-generator" ]; then \
		echo "  ✅ x86_64: dist/x86_64/meeting-notice-pdf-generator"; \
	else \
		echo "  ❌ x86_64: No generado"; \
	fi
	@if [ -f "dist/aarch64/meeting-notice-pdf-generator" ]; then \
		echo "  ✅ aarch64: dist/aarch64/meeting-notice-pdf-generator"; \
	else \
		echo "  ❌ aarch64: No generado"; \
	fi

build-apps-auto: ## Generar ejecutables para x86_64 (host) y ARM64 (jobs automáticos)
	@echo "$(GREEN)🚀 Generando ejecutables para x86_64 y ARM64 con jobs automáticos...$(NC)"
	@echo "$(YELLOW)Detectando número de CPUs disponibles...$(NC)"
	@$(eval JOBS := $(shell nproc 2>/dev/null || echo 2))
	@echo "$(YELLOW)Usando $(JOBS) jobs en paralelo...$(NC)"
	@$(MAKE) -j$(JOBS) build-cli-x86_64 build-cli-arm64
	@echo "$(GREEN)✅ Ejecutables generados en dist/x86_64/ y dist/aarch64/$(NC)"
	@echo "$(GREEN)📁 Estructura final:$(NC)"
	@echo "$(GREEN)📋 Ejecutables disponibles:$(NC)"
	@if [ -f "dist/x86_64/meeting-notice-pdf-generator" ]; then \
		echo "  ✅ x86_64: dist/x86_64/meeting-notice-pdf-generator"; \
	else \
		echo "  ❌ x86_64: No generado"; \
	fi
	@if [ -f "dist/aarch64/meeting-notice-pdf-generator" ]; then \
		echo "  ✅ aarch64: dist/aarch64/meeting-notice-pdf-generator"; \
	else \
		echo "  ❌ aarch64: No generado"; \
	fi

build-apps-j4: ## Generar ejecutables para x86_64 (host) y ARM64 (con 4 jobs)
	@echo "$(GREEN)🚀 Generando ejecutables para x86_64 y ARM64 con 4 jobs...$(NC)"
	@echo "$(YELLOW)Iniciando generación paralela con 4 jobs...$(NC)"
	@$(MAKE) -j4 build-cli-x86_64 build-cli-arm64
	@echo "$(GREEN)✅ Ejecutables generados en dist/x86_64/ y dist/aarch64/$(NC)"
	@echo "$(GREEN)📁 Estructura final:$(NC)"
	@echo "$(GREEN)📋 Ejecutables disponibles:$(NC)"
	@if [ -f "dist/x86_64/meeting-notice-pdf-generator" ]; then \
		echo "  ✅ x86_64: dist/x86_64/meeting-notice-pdf-generator"; \
	else \
		echo "  ❌ x86_64: No generado"; \
	fi
	@if [ -f "dist/aarch64/meeting-notice-pdf-generator" ]; then \
		echo "  ✅ aarch64: dist/aarch64/meeting-notice-pdf-generator"; \
	else \
		echo "  ❌ aarch64: No generado"; \
	fi 