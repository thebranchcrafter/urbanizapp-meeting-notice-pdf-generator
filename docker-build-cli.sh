#!/bin/bash
# Script para generar el ejecutable CLI usando Docker

set -e

echo "🐳 Generando ejecutable CLI con Docker..."

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado o no está disponible"
    exit 1
fi

# Crear directorio dist si no existe
mkdir -p dist

# Limpiar directorios anteriores
rm -rf build/
rm -f *.spec

echo "📦 Construyendo imagen Docker para generar el ejecutable..."

# Crear Dockerfile temporal para la generación
cat > Dockerfile.build << 'EOF'
FROM python:3.11-alpine

# Instalar dependencias del sistema para WeasyPrint
RUN apk add --no-cache \
    cairo \
    pango \
    gdk-pixbuf \
    libffi-dev \
    gcc \
    musl-dev \
    python3-dev \
    py3-pip

# Instalar PyInstaller
RUN pip install --no-cache-dir pyinstaller

# Crear directorio de trabajo
WORKDIR /app

# Copiar requirements y instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código de la aplicación
COPY app/ ./app/
COPY build_cli_simple.py .

# Generar el ejecutable
RUN python build_cli_simple.py

# El ejecutable se genera en /app/dist/
EOF

echo "🔨 Construyendo imagen Docker..."
docker build -f Dockerfile.build -t cli-builder .

echo "🚀 Ejecutando contenedor para generar el ejecutable..."
docker run --rm \
    -v "$(pwd)/dist:/app/dist" \
    -v "$(pwd)/build:/app/build" \
    cli-builder \
    sh -c "python build_cli_simple.py && chown -R $(id -u):$(id -g) /app/dist /app/build"

echo "🧹 Limpiando archivos temporales..."
rm -f Dockerfile.build
docker rmi cli-builder

echo "✅ Verificando el ejecutable generado..."
if [ -f "dist/meeting-notice-pdf-generator" ]; then
    echo "✅ Ejecutable generado exitosamente: dist/meeting-notice-pdf-generator"
    chmod +x dist/meeting-notice-pdf-generator
    
    echo "🧪 Probando el ejecutable..."
    if ./dist/meeting-notice-pdf-generator --help > /dev/null 2>&1; then
        echo "✅ Ejecutable funciona correctamente"
        echo ""
        echo "📋 Uso del ejecutable:"
        echo "   ./dist/meeting-notice-pdf-generator --json-file example_data.json --output meeting_notice.pdf"
    else
        echo "⚠️  Ejecutable generado pero puede tener problemas"
    fi
else
    echo "❌ No se encontró el ejecutable generado"
    echo "📁 Contenido del directorio dist:"
    ls -la dist/ || echo "  (directorio dist vacío o no existe)"
fi

echo ""
echo "🎉 Proceso completado!" 