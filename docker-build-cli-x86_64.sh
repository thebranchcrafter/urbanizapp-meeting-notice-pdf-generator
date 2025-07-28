#!/bin/bash
# Script para generar el ejecutable CLI para el sistema host x86_64 Ubuntu

set -e

echo "🐳 Generando ejecutable CLI para x86_64 Ubuntu (sistema host)..."

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado o no está disponible"
    exit 1
fi

# Crear directorio dist/x86_64 si no existe
mkdir -p dist/x86_64

# Limpiar directorios anteriores (con sudo si es necesario)
if [ -d "build/" ]; then
    echo "🧹 Limpiando directorio build anterior..."
    sudo rm -rf build/ 2>/dev/null || rm -rf build/ 2>/dev/null || echo "⚠️  No se pudo limpiar build/, continuando..."
fi
rm -f *.spec

echo "🚀 Ejecutando contenedor Docker x86_64 Ubuntu..."

# Usar docker run con Ubuntu x86_64 (misma arquitectura que el host)
docker run --rm \
    --platform linux/amd64 \
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
        echo '🔨 Generando ejecutable x86_64...' &&
        export WEASYPRINT_NO_SANDBOX=1 &&
        export CHROME_NO_SANDBOX=1 &&
        python3 build_cli_x86_64.py &&
        echo '🔧 Ajustando permisos...' &&
        chown -R $(id -u):$(id -g) /app/dist /app/build /app/*.spec &&
        chmod +x /app/dist/x86_64/meeting-notice-pdf-generator
    "

echo "✅ Verificando el ejecutable x86_64 generado..."
if [ -f "dist/x86_64/meeting-notice-pdf-generator" ]; then
    echo "✅ Ejecutable x86_64 generado exitosamente: dist/x86_64/meeting-notice-pdf-generator"
    
    echo "🔍 Verificando arquitectura del ejecutable..."
    file dist/x86_64/meeting-notice-pdf-generator
    
    echo "📊 Tamaño del ejecutable:"
    ls -lh dist/x86_64/meeting-notice-pdf-generator
    
    echo "🧪 Verificando dependencias del ejecutable..."
    if command -v ldd &> /dev/null; then
        echo "📋 Dependencias del ejecutable:"
        ldd dist/x86_64/meeting-notice-pdf-generator
    fi
    
    echo "🧪 Probando el ejecutable..."
    if ./dist/x86_64/meeting-notice-pdf-generator --help > /dev/null 2>&1; then
        echo "✅ Ejecutable funciona correctamente en el sistema host"
        echo ""
        echo "📋 Uso del ejecutable:"
        echo "   ./dist/x86_64/meeting-notice-pdf-generator --json-file example_data.json --output meeting_notice.pdf"
        echo ""
        echo "🧪 Ejemplo de uso:"
        echo "   ./dist/x86_64/meeting-notice-pdf-generator --json-file example_data.json --output test_output.pdf"
    else
        echo "⚠️  Ejecutable generado pero puede tener problemas"
        echo "🔍 Intentando ejecutar con más información:"
        ./dist/x86_64/meeting-notice-pdf-generator --help
    fi
else
    echo "❌ No se encontró el ejecutable generado"
    echo "📁 Contenido del directorio dist:"
    ls -la dist/ || echo "  (directorio dist vacío o no existe)"
fi

echo ""
echo "🎉 Proceso completado!" 