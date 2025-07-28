# Meeting Notice PDF Generator API

Una API REST para generar PDFs de convocatorias de reuniones usando WeasyPrint y FastAPI.

## Características

-   ✅ Generación de PDFs profesionales con WeasyPrint
-   ✅ API REST con FastAPI
-   ✅ Validación de datos con Pydantic
-   ✅ Templates HTML personalizables
-   ✅ Diseño responsive y moderno
-   ✅ Soporte para documentos adjuntos
-   ✅ Información de votación y puntos de reunión

## Instalación

### Prerrequisitos

-   Python 3.8 o superior
-   pip (gestor de paquetes de Python)

### Instalación de dependencias

```bash
# Clonar el repositorio
git clone <repository-url>
cd urbanizapp-meeting-notice-pdf-generator

# Instalar dependencias
pip install -r requirements.txt
```

### Dependencias del sistema (para WeasyPrint)

**Nota:** Si usas Docker (recomendado), no necesitas instalar estas dependencias localmente.

En sistemas basados en Ubuntu/Debian:

```bash
sudo apt-get install build-essential python3-dev python3-pip python3-setuptools python3-wheel python3-cffi libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 libffi-dev shared-mime-info
```

En sistemas basados en CentOS/RHEL:

```bash
sudo yum install redhat-rpm-config python3-devel python3-pip python3-setuptools python3-wheel python3-cffi libffi-devel cairo pango gdk-pixbuf2
```

## Uso

### Comando CLI

Además del servidor web, puedes generar PDFs directamente desde la línea de comandos usando un archivo JSON:

```bash
# Generar PDF desde un archivo JSON
python -m app.cli --json-file example_data.json --output meeting_notice.pdf

# Generar PDF desde stdin
cat example_data.json | python -m app.cli --json-file - --output meeting_notice.pdf

# Generar PDF en un directorio específico (nombre automático basado en meeting ID)
python -m app.cli --json-file example_data.json --output-dir ./pdfs/

# Ver ayuda del comando
python -m app.cli --help
```

**Opciones disponibles:**

-   `--json-file, -j`: Archivo JSON con los datos de la reunión (usa "-" para stdin)
-   `--output, -o`: Archivo PDF de salida
-   `--output-dir, -d`: Directorio de salida (nombre automático basado en meeting ID)
-   `--verbose, -v`: Habilitar logging detallado

### Generar Ejecutable CLI

Puedes generar un ejecutable independiente del CLI que no requiere Python instalado:

```bash
# Generar ejecutable usando Makefile (recomendado)
make build-cli

# Generar ejecutable con Docker (evita problemas de sandbox)
make build-cli-docker

# Generar ejecutable con Docker (versión simple)
make build-cli-docker-simple

# Probar el ejecutable generado
make test-cli

# Limpiar archivos del ejecutable
make clean-cli
```

**O manualmente:**

```bash
# Instalar PyInstaller
pip install pyinstaller

# Generar ejecutable
python build_cli.py

# Usar el ejecutable
./dist/meeting-notice-pdf-generator --json-file example_data.json --output meeting_notice.pdf
```

El ejecutable se genera en el directorio `dist/` y incluye todas las dependencias necesarias.

**Usando Docker directamente:**

```bash
# Versión simple con docker run
./docker-build-cli-simple.sh

# Versión completa con Dockerfile
./docker-build-cli.sh
```

**Nota:** Si encuentras problemas de sandbox en Linux, usa las opciones con Docker que evitan completamente estos problemas.

### Ejecutar la aplicación web

#### Con Makefile (recomendado)

```bash
# Ver todos los comandos disponibles
make help

# 🚀 INICIAR DESARROLLO RÁPIDO (recomendado)
make start

# Configurar entorno de desarrollo local
make dev-setup

# Ejecutar en modo desarrollo local
make dev

# Ejecutar en modo producción
make prod

# Probar la API
make test-api

# Verificar estado
make status
```

#### Comandos directos

```bash
# Ejecutar en modo desarrollo
python -m app.main

# O usando uvicorn directamente
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

La API estará disponible en `http://localhost:8000`

### Documentación de la API

Una vez ejecutada la aplicación, puedes acceder a:

-   **Documentación interactiva**: http://localhost:8000/docs
-   **Documentación alternativa**: http://localhost:8000/redoc
-   **Health check**: http://localhost:8000/health

## Endpoints

### POST /meeting-notice/generate-pdf

Genera un PDF de convocatoria de reunión.

**Payload de ejemplo:**

```json
{
    "id": "01HXYZ123456789ABCDEF",
    "community_id": "01HXYZ987654321FEDCBA",
    "title": "Reunión ordinaria de la Comunidad",
    "meeting_type": "ordinary",
    "date_time": 1704067200,
    "location": "Centro Comunitario Principal",
    "description": "Reunión mensual para discutir temas importantes de la comunidad y planificar actividades futuras.",
    "status": 1,
    "documents": [
        {
            "id": "01HXYZ111111111111111",
            "name": "agenda_reunion_enero.pdf",
            "signed_url": "https://example-bucket.s3.amazonaws.com/documents/agenda_reunion_enero.pdf?signature=abc123",
            "content_type": "application/pdf",
            "size": 245760
        }
    ],
    "meeting_notice_file": {
        "id": "01HXYZ333333333333333",
        "name": "convocatoria_reunion.pdf",
        "signed_url": "https://example-bucket.s3.amazonaws.com/documents/convocatoria_reunion.pdf?signature=ghi789",
        "content_type": "application/pdf",
        "size": 156672
    },
    "meeting_points": [
        {
            "id": "01HXYZ444444444444444",
            "meeting_id": "01HXYZ123456789ABCDEF",
            "title": "Revisión del Presupuesto Anual",
            "description": "Discutir y aprobar el presupuesto para el próximo año fiscal",
            "documents": [],
            "voting": {
                "voteType": "approval",
                "options": [
                    {
                        "id": "01HXYZ666666666666666",
                        "option": "Aprobar",
                        "order": 1
                    },
                    {
                        "id": "01HXYZ777777777777777",
                        "option": "Rechazar",
                        "order": 2
                    }
                ]
            },
            "created_at": "2024-01-15T10:30:00Z",
            "updated_at": "2024-01-15T10:30:00Z"
        }
    ]
}
```

**Respuesta:**

-   Content-Type: `application/pdf`
-   Archivo PDF descargable

### GET /health

Endpoint de health check para monitoreo.

**Respuesta:**

```json
{
    "status": "healthy",
    "service": "meeting-notice-pdf-generator",
    "version": "1.0.0"
}
```

## Estructura del Proyecto

```
urbanizapp-meeting-notice-pdf-generator/
├── app/
│   ├── __init__.py
│   ├── main.py              # Aplicación FastAPI principal
│   ├── cli.py               # Comando CLI para generación de PDFs
│   ├── models.py            # Modelos Pydantic
│   ├── pdf_generator.py     # Servicio de generación de PDFs
│   ├── templates/
│   │   └── meeting_notice.html  # Template HTML
│   └── static/
│       └── styles.css       # Estilos CSS
├── example_data.json        # Datos de ejemplo para el CLI
├── build_cli.py             # Script para generar ejecutable CLI
├── requirements.txt         # Dependencias de Python
├── Makefile                # Comandos de automatización
├── Dockerfile              # Configuración Docker
├── docker-compose.yml      # Orquestación Docker
├── test_example.py         # Script de prueba
└── README.md               # Este archivo
```

## Personalización

### Modificar el diseño del PDF

1. **Template HTML**: Edita `app/templates/meeting_notice.html`
2. **Estilos CSS**: Modifica `app/static/styles.css`

### Agregar nuevos campos

1. Actualiza los modelos en `app/models.py`
2. Modifica el template HTML para mostrar los nuevos campos
3. Actualiza la lógica en `app/pdf_generator.py` si es necesario

## Desarrollo

### Comandos de desarrollo con Makefile

```bash
# Formatear código
make format

# Verificar formato
make check

# Ejecutar linter
make lint

# Ejecutar tests
make test

# Pipeline de CI completo
make ci

# Limpiar archivos temporales
make clean
```

### Comandos directos

```bash
# Formatear código
black app/
isort app/

# Ejecutar linter
flake8 app/

# Ejecutar tests
pytest
```

## Despliegue

### Docker con Makefile (Optimizado con Alpine Linux)

```bash
# 🚀 DESARROLLO RÁPIDO CON DOCKER (recomendado)
make start

# Desarrollo con Docker Compose
make docker-compose-dev

# Desarrollo con Docker directo
make docker-dev

# Ver logs del contenedor
make docker-logs

# Detener contenedores
make docker-compose-down

# Limpiar Docker
make docker-clean
```

### Docker manual (Optimizado)

```dockerfile
FROM python:3.11-alpine

# Instalar dependencias del sistema para WeasyPrint en Alpine
RUN apk add --no-cache \
    cairo \
    pango \
    gdk-pixbuf \
    libffi-dev \
    gcc \
    musl-dev \
    python3-dev

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Variables de entorno

```bash
# Puerto de la aplicación
PORT=8000

# Nivel de logging
LOG_LEVEL=INFO
```

## Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Soporte

Si tienes problemas o preguntas:

1. Revisa la documentación de la API en `/docs`
2. Verifica los logs de la aplicación
3. Abre un issue en el repositorio

## Changelog

### v1.1.0

-   ✅ Comando CLI para generación de PDFs desde JSON
-   ✅ Soporte para entrada desde stdin
-   ✅ Generación automática de nombres de archivo
-   ✅ Validación de datos en el CLI
-   ✅ Generación de ejecutable independiente con PyInstaller
-   ✅ Scripts de automatización para build y testing

### v1.0.0

-   ✅ Implementación inicial de la API
-   ✅ Generación de PDFs con WeasyPrint
-   ✅ Endpoint POST /meeting-notice/generate-pdf
-   ✅ Templates HTML y CSS profesionales
-   ✅ Validación de datos con Pydantic
