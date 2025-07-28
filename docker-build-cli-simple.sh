#!/bin/bash
# Script simple para generar el ejecutable CLI usando Docker

set -e

echo "🐳 Generando ejecutable CLI con Docker (versión simple)..."

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado o no está disponible"
    exit 1
fi

# Crear directorio dist si no existe
mkdir -p dist

# Limpiar directorios anteriores (con sudo si es necesario)
if [ -d "build/" ]; then
    echo "🧹 Limpiando directorio build anterior..."
    sudo rm -rf build/ 2>/dev/null || rm -rf build/ 2>/dev/null || echo "⚠️  No se pudo limpiar build/, continuando..."
fi
rm -f *.spec

echo "🚀 Ejecutando contenedor Docker para generar el ejecutable..."

# Usar docker run directamente con volúmenes
docker run --rm \
    -v "$(pwd):/app" \
    -w /app \
    python:3.11-alpine \
    sh -c "
        echo '📦 Instalando dependencias del sistema...' &&
        apk add --no-cache cairo pango gdk-pixbuf libffi-dev gcc musl-dev python3-dev &&
        echo '📦 Instalando PyInstaller...' &&
        pip install --no-cache-dir pyinstaller &&
        echo '📦 Instalando dependencias de Python...' &&
        pip install --no-cache-dir -r requirements.txt &&
        echo '🔨 Generando ejecutable...' &&
        export WEASYPRINT_NO_SANDBOX=1 &&
        export CHROME_NO_SANDBOX=1 &&
        python build_cli_simple.py &&
        echo '🔧 Ajustando permisos...' &&
        chown -R $(id -u):$(id -g) /app/dist /app/build /app/*.spec &&
        chmod +x /app/dist/meeting-notice-pdf-generator
    "

echo "✅ Verificando el ejecutable generado..."
if [ -f "dist/meeting-notice-pdf-generator" ]; then
    echo "✅ Ejecutable generado exitosamente: dist/meeting-notice-pdf-generator"
    
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