#!/bin/bash
# Script para generar el ejecutable CLI usando Docker con Ubuntu

set -e

echo "🐳 Generando ejecutable CLI con Docker (Ubuntu)..."

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

echo "🚀 Ejecutando contenedor Docker con Ubuntu..."

# Usar docker run con Ubuntu en lugar de Alpine
docker run --rm \
    -v "$(pwd):/app" \
    -w /app \
    ubuntu:22.04 \
    bash -c "
        echo '📦 Actualizando sistema...' &&
        apt-get update &&
        echo '📦 Instalando dependencias del sistema...' &&
        apt-get install -y python3 python3-pip python3-venv build-essential &&
        apt-get install -y libcairo2-dev libpango1.0-dev libgdk-pixbuf2.0-dev libffi-dev &&
        echo '📦 Instalando PyInstaller...' &&
        pip3 install --no-cache-dir pyinstaller &&
        echo '📦 Instalando dependencias de Python...' &&
        pip3 install --no-cache-dir -r requirements.txt &&
        echo '🔨 Generando ejecutable...' &&
        export WEASYPRINT_NO_SANDBOX=1 &&
        export CHROME_NO_SANDBOX=1 &&
        python3 build_cli_simple.py &&
        echo '🔧 Ajustando permisos...' &&
        chown -R $(id -u):$(id -g) /app/dist /app/build /app/*.spec &&
        chmod +x /app/dist/meeting-notice-pdf-generator
    "

echo "✅ Verificando el ejecutable generado..."
if [ -f "dist/meeting-notice-pdf-generator" ]; then
    echo "✅ Ejecutable generado exitosamente: dist/meeting-notice-pdf-generator"
    
    echo "🔍 Verificando arquitectura del ejecutable..."
    file dist/meeting-notice-pdf-generator
    
    echo "🧪 Probando el ejecutable..."
    if ./dist/meeting-notice-pdf-generator --help > /dev/null 2>&1; then
        echo "✅ Ejecutable funciona correctamente"
        echo ""
        echo "📋 Uso del ejecutable:"
        echo "   ./dist/meeting-notice-pdf-generator --json-file example_data.json --output meeting_notice.pdf"
    else
        echo "⚠️  Ejecutable generado pero puede tener problemas"
        echo "🔍 Intentando ejecutar con más información:"
        ./dist/meeting-notice-pdf-generator --help
    fi
else
    echo "❌ No se encontró el ejecutable generado"
    echo "📁 Contenido del directorio dist:"
    ls -la dist/ || echo "  (directorio dist vacío o no existe)"
fi

echo ""
echo "🎉 Proceso completado!" 