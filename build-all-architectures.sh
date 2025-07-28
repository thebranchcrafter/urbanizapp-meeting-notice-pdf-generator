#!/bin/bash
# Script para generar ejecutables para múltiples arquitecturas

set -e

echo "🚀 Generando ejecutables para múltiples arquitecturas..."

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado o no está disponible"
    exit 1
fi

# Crear directorio dist si no existe
mkdir -p dist

# Limpiar directorios anteriores
if [ -d "build/" ]; then
    echo "🧹 Limpiando directorio build anterior..."
    sudo rm -rf build/ 2>/dev/null || rm -rf build/ 2>/dev/null || echo "⚠️  No se pudo limpiar build/, continuando..."
fi
rm -f *.spec

# Función para generar ejecutable para una arquitectura específica
generate_for_arch() {
    local arch=$1
    local platform=$2
    local image=$3
    
    echo ""
    echo "🔨 Generando ejecutable para $arch..."
    echo "📦 Usando imagen: $image"
    
    # Crear directorio para la arquitectura
    mkdir -p "dist/$arch"
    
    # Verificar si necesitamos QEMU para esta arquitectura
    if [ "$arch" != "x86_64" ] && [ "$arch" != "amd64" ]; then
        if ! command -v qemu-aarch64-static &> /dev/null; then
            echo "📦 Instalando QEMU para emulación ARM64..."
            sudo apt-get update
            sudo apt-get install -y qemu-user-static binfmt-support
        fi
    fi
    
    # Generar ejecutable
    docker run --rm \
        --platform "$platform" \
        -v "$(pwd):/app" \
        -w /app \
        "$image" \
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
            echo '🔨 Generando ejecutable $arch...' &&
            export WEASYPRINT_NO_SANDBOX=1 &&
            export CHROME_NO_SANDBOX=1 &&
            python3 build_cli_simple.py &&
            echo '🔧 Ajustando permisos...' &&
            chown -R $(id -u):$(id -g) /app/dist /app/build /app/*.spec &&
            chmod +x /app/dist/$arch/meeting-notice-pdf-generator
        "
    
    if [ -f "dist/$arch/meeting-notice-pdf-generator" ]; then
        echo "✅ Ejecutable $arch generado exitosamente"
        echo "📊 Tamaño: $(ls -lh dist/$arch/meeting-notice-pdf-generator | awk '{print $5}')"
        echo "🔍 Arquitectura: $(file dist/$arch/meeting-notice-pdf-generator | cut -d',' -f1)"
    else
        echo "❌ Error generando ejecutable para $arch"
    fi
}

# Generar para diferentes arquitecturas
echo "📋 Generando ejecutables para las siguientes arquitecturas:"

# x86_64 (AMD64)
generate_for_arch "x86_64" "linux/amd64" "ubuntu:22.04"

# ARM64
generate_for_arch "aarch64" "linux/arm64" "ubuntu:22.04"

# ARM32 (opcional)
# generate_for_arch "armv7l" "linux/arm/v7" "ubuntu:22.04"

echo ""
echo "🎉 Generación de ejecutables completada!"
echo ""
echo "📁 Estructura de directorios generada:"
tree dist/ 2>/dev/null || ls -la dist/

echo ""
echo "📋 Ejecutables disponibles:"
for arch_dir in dist/*/; do
    if [ -d "$arch_dir" ]; then
        arch=$(basename "$arch_dir")
        exe_path="$arch_dir/meeting-notice-pdf-generator"
        if [ -f "$exe_path" ]; then
            echo "  ✅ $arch: $exe_path"
        else
            echo "  ❌ $arch: No generado"
        fi
    fi
done

echo ""
echo "💡 Para usar un ejecutable específico:"
echo "   ./dist/x86_64/meeting-notice-pdf-generator --help"
echo "   ./dist/aarch64/meeting-notice-pdf-generator --help" 