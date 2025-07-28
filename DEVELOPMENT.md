# Guía de Desarrollo - Hot Reload

Esta guía explica cómo usar el sistema de hot reload optimizado para desarrollo.

## 🚀 Inicio Rápido

### Opción 1: Hot Reload Optimizado (Recomendado)

```bash
make start
# o
make docker-compose-dev-hot
```

### Opción 2: Desarrollo Estándar

```bash
make docker-compose-dev
```

## 🔥 Hot Reload Optimizado

El sistema de hot reload optimizado incluye:

### Características

-   **Volúmenes específicos**: Solo monta los directorios que necesitan hot reload
-   **Cache de Python**: Volumen dedicado para `__pycache__`
-   **Modo delegado**: Mejor rendimiento en sistemas de archivos
-   **Uvicorn con reload**: Reinicio automático al detectar cambios
-   **Polling forzado**: Compatible con sistemas de archivos que no soportan inotify

### Configuración de Volúmenes

```yaml
volumes:
    # Código de la aplicación (hot reload)
    - ./app:/app/app:delegated

    # Archivos de configuración (solo lectura)
    - ./requirements.txt:/app/requirements.txt:ro

    # Cache de Python (volumen nombrado)
    - python_cache:/app/__pycache__
```

### Variables de Entorno para Desarrollo

```yaml
environment:
    - PYTHONPATH=/app
    - LOG_LEVEL=DEBUG
    - PYTHONDONTWRITEBYTECODE=1
    - PYTHONUNBUFFERED=1
    - WATCHFILES_FORCE_POLLING=true
```

## 📁 Estructura de Volúmenes

```
Proyecto Local          Contenedor Docker
├── app/               → /app/app/          (hot reload)
│   ├── templates/     → /app/app/templates/ (incluido en app/)
│   └── static/       → /app/app/static/   (incluido en app/)
├── requirements.txt  → /app/requirements.txt (solo lectura)
└── __pycache__/      → volumen nombrado   (cache)
```

## 🛠️ Comandos Útiles

### Desarrollo

```bash
# Iniciar con hot reload
make start

# Ver logs en tiempo real
make docker-compose-dev-logs

# Detener desarrollo
make docker-compose-dev-down

# Reiniciar contenedor
make docker-restart
```

### Testing

```bash
# Probar la API
make test-api

# Verificar estado
make status

# Abrir documentación
make open-docs
```

### Limpieza

```bash
# Limpiar cache y archivos temporales
make clean

# Limpiar contenedores
make docker-clean
```

## 🔄 Cómo Funciona el Hot Reload

1. **Detección de Cambios**: Uvicorn monitorea los archivos Python en `/app/app/`
2. **Reinicio Automático**: Al detectar cambios, reinicia automáticamente el servidor
3. **Volúmenes Optimizados**: Solo los archivos necesarios están montados
4. **Cache Persistente**: El cache de Python se mantiene entre reinicios

## 🐛 Solución de Problemas

### Hot Reload No Funciona

```bash
# Verificar que el contenedor está ejecutándose
docker ps

# Ver logs para errores
make docker-compose-dev-logs

# Reiniciar contenedor
make docker-restart
```

### Cambios No Se Reflejan

```bash
# Verificar que estás editando en el directorio correcto
ls -la app/

# Forzar reinicio manual
docker-compose -f docker-compose.dev.yml restart
```

### Problemas de Permisos

```bash
# Verificar permisos de archivos
ls -la app/

# Corregir permisos si es necesario
chmod -R 755 app/
```

## 📊 Monitoreo

### Health Check

```bash
curl http://localhost:8000/health
```

### Logs en Tiempo Real

```bash
make docker-compose-dev-logs
```

### Estado del Contenedor

```bash
docker ps
docker stats
```

## 🔧 Configuración Avanzada

### Personalizar Volúmenes

Edita `docker-compose.dev.yml` para agregar más directorios:

```yaml
volumes:
    - ./app:/app/app:delegated
    - ./config:/app/config:ro # Nuevo directorio
    - ./data:/app/data:ro # Nuevo directorio
```

### Cambiar Puerto

```bash
# En docker-compose.dev.yml
ports:
  - "8080:8000"  # Puerto local:puerto contenedor
```

### Variables de Entorno Adicionales

```yaml
environment:
    - DEBUG=true
    - ENVIRONMENT=development
    - DATABASE_URL=sqlite:///dev.db
```

## 🎯 Mejores Prácticas

1. **Usar `make start`**: Comando principal para desarrollo
2. **Monitorear logs**: Usar `make docker-compose-dev-logs`
3. **Limpiar regularmente**: `make clean` para evitar problemas de cache
4. **Verificar health check**: Asegurar que la app está funcionando
5. **Usar volúmenes específicos**: Evitar montar directorios innecesarios

## 📚 Recursos Adicionales

-   [Documentación de Uvicorn](https://www.uvicorn.org/)
-   [Docker Compose Volumes](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes)
-   [FastAPI Development](https://fastapi.tiangolo.com/tutorial/)
