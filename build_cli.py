#!/usr/bin/env python3
"""
Script para generar un ejecutable del CLI usando PyInstaller.
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def install_pyinstaller():
    """Instalar PyInstaller si no está disponible"""
    try:
        import PyInstaller
        print("✅ PyInstaller ya está instalado")
    except ImportError:
        print("📦 Instalando PyInstaller...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])
        print("✅ PyInstaller instalado correctamente")

def create_spec_file():
    """Crear archivo .spec para PyInstaller con configuraciones optimizadas"""
    spec_content = '''# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['app/cli.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('app/templates', 'app/templates'),
        ('app/static', 'app/static'),
    ],
    hiddenimports=[
        'weasyprint',
        'jinja2',
        'pydantic',
        'fastapi',
        'uvicorn',
        'app.models',
        'app.pdf_generator',
        'cairocffi',
        'cairosvg',
        'pango',
        'pangocairo',
        'gdkpixbuf',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'tkinter',
        'matplotlib',
        'numpy',
        'scipy',
        'pandas',
        'IPython',
        'jupyter',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='meeting-notice-pdf-generator',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
'''
    
    with open('meeting_notice_pdf_generator.spec', 'w', encoding='utf-8') as f:
        f.write(spec_content)
    
    print("✅ Archivo .spec creado: meeting_notice_pdf_generator.spec")

def build_executable():
    """Generar el ejecutable con configuraciones para evitar problemas de sandbox"""
    print("🔨 Generando ejecutable...")
    
    # Configurar variables de entorno para evitar problemas de sandbox
    env = os.environ.copy()
    env.update({
        'PYTHONPATH': os.getcwd(),
        'WEASYPRINT_NO_SANDBOX': '1',  # Deshabilitar sandbox de WeasyPrint
        'CHROME_NO_SANDBOX': '1',      # Deshabilitar sandbox de Chrome
    })
    
    try:
        # Usar el archivo .spec personalizado
        subprocess.check_call([
            sys.executable, "-m", "PyInstaller",
            "--clean",
            "--noconfirm",
            "meeting_notice_pdf_generator.spec"
        ], env=env)
        
        print("✅ Ejecutable generado correctamente")
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Error durante la generación: {e}")
        print("\n🔧 Intentando método alternativo...")
        
        # Método alternativo sin archivo .spec
        try:
            subprocess.check_call([
                sys.executable, "-m", "PyInstaller",
                "--onefile",
                "--console",
                "--clean",
                "--noconfirm",
                "--add-data", "app/templates:app/templates",
                "--add-data", "app/static:app/static",
                "--hidden-import", "weasyprint",
                "--hidden-import", "jinja2",
                "--hidden-import", "pydantic",
                "--hidden-import", "app.models",
                "--hidden-import", "app.pdf_generator",
                "--exclude-module", "tkinter",
                "--exclude-module", "matplotlib",
                "--exclude-module", "numpy",
                "--exclude-module", "scipy",
                "--exclude-module", "pandas",
                "--exclude-module", "IPython",
                "--exclude-module", "jupyter",
                "app/cli.py"
            ], env=env)
            
            print("✅ Ejecutable generado correctamente (método alternativo)")
            
        except subprocess.CalledProcessError as e2:
            print(f"❌ Error también con método alternativo: {e2}")
            raise

def create_distribution():
    """Crear distribución con archivos adicionales"""
    dist_dir = Path("dist")
    if dist_dir.exists():
        shutil.rmtree(dist_dir)
    
    # Crear directorio de distribución
    dist_dir.mkdir()
    
    # Buscar el ejecutable (puede tener diferentes nombres)
    exe_name = "meeting-notice-pdf-generator"
    exe_path = dist_dir / exe_name
    
    if not exe_path.exists():
        # Buscar otros posibles nombres
        for file in dist_dir.glob("*"):
            if file.is_file() and file.stat().st_mode & 0o111:  # Es ejecutable
                exe_path = file
                break
    
    if exe_path.exists():
        print(f"✅ Ejecutable disponible en: {exe_path.absolute()}")
        
        # Hacer el archivo ejecutable
        exe_path.chmod(0o755)
    else:
        print("⚠️  No se encontró el ejecutable generado")
    
    # Crear README para la distribución
    readme_content = """# Meeting Notice PDF Generator CLI

## Uso

```bash
# Generar PDF desde un archivo JSON
./meeting-notice-pdf-generator --json-file example_data.json --output meeting_notice.pdf

# Generar PDF desde stdin
cat example_data.json | ./meeting-notice-pdf-generator --json-file - --output meeting_notice.pdf

# Generar PDF en un directorio específico
./meeting-notice-pdf-generator --json-file example_data.json --output-dir ./pdfs/

# Ver ayuda
./meeting-notice-pdf-generator --help
```

## Opciones

- `--json-file, -j`: Archivo JSON con los datos de la reunión (usa "-" para stdin)
- `--output, -o`: Archivo PDF de salida
- `--output-dir, -d`: Directorio de salida (nombre automático basado en meeting ID)
- `--verbose, -v`: Habilitar logging detallado

## Solución de problemas

Si encuentras errores relacionados con sandbox, ejecuta:

```bash
export WEASYPRINT_NO_SANDBOX=1
export CHROME_NO_SANDBOX=1
./meeting-notice-pdf-generator --json-file example_data.json --output test.pdf
```

## Ejemplo de JSON

Ver el archivo `example_data.json` para un ejemplo del formato de datos requerido.
"""
    
    with open(dist_dir / "README.md", 'w', encoding='utf-8') as f:
        f.write(readme_content)
    
    # Copiar archivo de ejemplo
    if Path("example_data.json").exists():
        shutil.copy("example_data.json", dist_dir / "example_data.json")
    
    print("✅ Distribución creada en el directorio 'dist'")

def main():
    """Función principal"""
    print("🚀 Iniciando generación del ejecutable CLI...")
    
    try:
        # Instalar PyInstaller
        install_pyinstaller()
        
        # Crear archivo .spec
        create_spec_file()
        
        # Generar ejecutable
        build_executable()
        
        # Crear distribución
        create_distribution()
        
        print("\n🎉 ¡Ejecutable generado exitosamente!")
        print("\n📁 Archivos generados:")
        print("   - dist/meeting-notice-pdf-generator (ejecutable)")
        print("   - dist/README.md (documentación)")
        print("   - dist/example_data.json (ejemplo)")
        
        print("\n💡 Para usar el ejecutable:")
        print("   ./dist/meeting-notice-pdf-generator --help")
        
        print("\n⚠️  Si encuentras errores de sandbox, ejecuta:")
        print("   export WEASYPRINT_NO_SANDBOX=1")
        print("   export CHROME_NO_SANDBOX=1")
        print("   ./dist/meeting-notice-pdf-generator --json-file example_data.json --output test.pdf")
        
    except Exception as e:
        print(f"❌ Error durante la generación: {e}")
        print("\n🔧 Soluciones posibles:")
        print("   1. Ejecutar con variables de entorno:")
        print("      export WEASYPRINT_NO_SANDBOX=1")
        print("      export CHROME_NO_SANDBOX=1")
        print("      make build-cli")
        print("   2. Usar Docker para generar el ejecutable:")
        print("      docker run --rm -v $(pwd):/app -w /app python:3.11-alpine sh -c 'apk add --no-cache cairo pango gdk-pixbuf && pip install pyinstaller && python build_cli.py'")
        sys.exit(1)

if __name__ == "__main__":
    main() 