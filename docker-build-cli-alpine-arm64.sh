#!/bin/bash
# Script para generar el ejecutable CLI para Linux ARM64 usando Alpine

set -e

echo "🐳 Generando ejecutable CLI para Linux ARM64 (Alpine)..."

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado o no está disponible"
    exit 1
fi

# Verificar que QEMU esté disponible
if ! command -v qemu-aarch64-static &> /dev/null; then
    echo "📦 Instalando QEMU para emulación ARM64..."
    sudo apt-get update
    sudo apt-get install -y qemu-user-static
fi

# Crear directorio dist si no existe
mkdir -p dist

# Limpiar directorios anteriores (con sudo si es necesario)
if [ -d "build/" ]; then
    echo "🧹 Limpiando directorio build anterior..."
    sudo rm -rf build/ 2>/dev/null || rm -rf build/ 2>/dev/null || echo "⚠️  No se pudo limpiar build/, continuando..."
fi
rm -f *.spec

echo "🚀 Ejecutando contenedor Docker Alpine ARM64 con QEMU..."

# Usar docker run con Alpine ARM64 y QEMU
docker run --rm \
    --platform linux/arm64 \
    -v "$(pwd):/app" \
    -w /app \
    alpine:latest \
    sh -c "
        echo '📦 Instalando dependencias del sistema...' &&
        apk add --no-cache cairo pango gdk-pixbuf libffi-dev gcc musl-dev python3-dev py3-pip &&
        echo '📦 Instalando PyInstaller...' &&
        pip3 install --no-cache-dir pyinstaller &&
        echo '📦 Instalando dependencias de Python...' &&
        pip3 install --no-cache-dir -r requirements.txt &&
        echo '🔨 Generando ejecutable ARM64...' &&
        export WEASYPRINT_NO_SANDBOX=1 &&
        export CHROME_NO_SANDBOX=1 &&
        python3 build_cli_simple.py &&
        echo '🔧 Ajustando permisos...' &&
        chown -R $(id -u):$(id -g) /app/dist /app/build /app/*.spec &&
        chmod +x /app/dist/meeting-notice-pdf-generator
    "

echo "✅ Verificando el ejecutable ARM64 generado..."
if [ -f "dist/meeting-notice-pdf-generator" ]; then
    echo "✅ Ejecutable ARM64 generado exitosamente: dist/meeting-notice-pdf-generator"
    
    echo "🔍 Verificando arquitectura del ejecutable..."
    file dist/meeting-notice-pdf-generator
    
    echo "📊 Tamaño del ejecutable:"
    ls -lh dist/meeting-notice-pdf-generator
    
    echo ""
    echo "📋 Uso del ejecutable ARM64:"
    echo "   ./dist/meeting-notice-pdf-generator --json-file example_data.json --output meeting_notice.pdf"
    echo ""
    echo "💡 Para usar en un sistema ARM64:"
    echo "   1. Copia el archivo dist/meeting-notice-pdf-generator al sistema ARM64"
    echo "   2. Dale permisos de ejecución: chmod +x meeting-notice-pdf-generator"
    echo "   3. Ejecuta: ./meeting-notice-pdf-generator --help"
else
    echo "❌ No se encontró el ejecutable generado"
    echo "📁 Contenido del directorio dist:"
    ls -la dist/ || echo "  (directorio dist vacío o no existe)"
fi

echo ""
echo "🎉 Proceso completado!" 