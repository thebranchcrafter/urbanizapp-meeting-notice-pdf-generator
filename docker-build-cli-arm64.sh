#!/bin/bash
# Script para generar el ejecutable CLI para Linux ARM64

set -e

echo "🐳 Generando ejecutable CLI para Linux ARM64..."

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado o no está disponible"
    exit 1
fi

# Verificar que QEMU esté disponible
if ! command -v qemu-aarch64-static &> /dev/null; then
    echo "📦 Instalando QEMU para emulación ARM64..."
    sudo apt-get update
    sudo apt-get install -y qemu-user-static binfmt-support
    echo "✅ QEMU instalado correctamente"
fi

# Crear directorio dist/aarch64 si no existe
mkdir -p dist/aarch64

# Limpiar directorios anteriores (con sudo si es necesario)
if [ -d "build/" ]; then
    echo "🧹 Limpiando directorio build anterior..."
    sudo rm -rf build/ 2>/dev/null || rm -rf build/ 2>/dev/null || echo "⚠️  No se pudo limpiar build/, continuando..."
fi
rm -f *.spec

echo "🚀 Ejecutando contenedor Docker ARM64 con QEMU..."

# Usar docker run con Ubuntu ARM64 y QEMU
docker run --rm \
    --platform linux/arm64 \
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
        echo '🔨 Generando ejecutable ARM64...' &&
        export WEASYPRINT_NO_SANDBOX=1 &&
        export CHROME_NO_SANDBOX=1 &&
        python3 build_cli_arm64.py &&
        echo '🔧 Ajustando permisos...' &&
        chown -R $(id -u):$(id -g) /app/dist /app/build /app/*.spec &&
        chmod +x /app/dist/aarch64/meeting-notice-pdf-generator
    "

echo "✅ Verificando el ejecutable ARM64 generado..."
if [ -f "dist/aarch64/meeting-notice-pdf-generator" ]; then
    echo "✅ Ejecutable ARM64 generado exitosamente: dist/aarch64/meeting-notice-pdf-generator"
    
    echo "🔍 Verificando arquitectura del ejecutable..."
    file dist/aarch64/meeting-notice-pdf-generator
    
    echo "📊 Tamaño del ejecutable:"
    ls -lh dist/aarch64/meeting-notice-pdf-generator
    
    echo ""
    echo "📋 Uso del ejecutable ARM64:"
    echo "   ./dist/aarch64/meeting-notice-pdf-generator --json-file example_data.json --output meeting_notice.pdf"
    echo ""
    echo "💡 Para usar en un sistema ARM64:"
    echo "   1. Copia el archivo dist/aarch64/meeting-notice-pdf-generator al sistema ARM64"
    echo "   2. Dale permisos de ejecución: chmod +x meeting-notice-pdf-generator"
    echo "   3. Ejecuta: ./meeting-notice-pdf-generator --help"
    echo ""
    echo "⚠️  Nota: Este ejecutable NO funcionará en tu sistema x86_64 actual"
    echo "   Está compilado específicamente para sistemas Linux ARM64"
else
    echo "❌ No se encontró el ejecutable generado"
    echo "📁 Contenido del directorio dist/aarch64:"
    ls -la dist/aarch64/ || echo "  (directorio dist/aarch64 vacío o no existe)"
fi

echo ""
echo "🎉 Proceso completado!" 