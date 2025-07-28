#!/usr/bin/env python3
"""
Script simplificado para generar un ejecutable del CLI usando PyInstaller.
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def main():
    """Función principal simplificada"""
    print("🚀 Iniciando generación del ejecutable CLI (versión simplificada)...")
    
    # Detectar arquitectura del sistema
    import platform
    arch = platform.machine()
    print(f"🔍 Arquitectura detectada: {arch}")
    
    # Crear directorio específico para la arquitectura
    arch_dir = f"dist/{arch}"
    os.makedirs(arch_dir, exist_ok=True)
    print(f"📁 Usando directorio: {arch_dir}")
    
    # Configurar variables de entorno
    env = os.environ.copy()
    env.update({
        'PYTHONPATH': os.getcwd(),
        'WEASYPRINT_NO_SANDBOX': '1',
        'CHROME_NO_SANDBOX': '1',
    })
    
    # Limpiar directorios anteriores
    for dir_name in ['dist', 'build']:
        if Path(dir_name).exists():
            shutil.rmtree(dir_name)
    
    # Comando PyInstaller simplificado
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--onefile",
        "--console",
        "--clean",
        "--noconfirm",
        "--distpath", arch_dir,  # Usar directorio específico de arquitectura
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
        "--name", "meeting-notice-pdf-generator",
        "app/cli.py"
    ]
    
    print(f"🔨 Ejecutando comando: {' '.join(cmd)}")
    
    try:
        # Ejecutar PyInstaller con output detallado
        result = subprocess.run(
            cmd,
            env=env,
            capture_output=True,
            text=True,
            timeout=300  # 5 minutos de timeout
        )
        
        print(f"📋 Código de salida: {result.returncode}")
        
        if result.stdout:
            print("📤 STDOUT:")
            print(result.stdout)
        
        if result.stderr:
            print("📤 STDERR:")
            print(result.stderr)
        
        if result.returncode == 0:
            print("✅ PyInstaller completado exitosamente")
            
            # Verificar si se generó el ejecutable
            exe_path = Path(f"{arch_dir}/meeting-notice-pdf-generator")
            if exe_path.exists():
                print(f"✅ Ejecutable encontrado: {exe_path.absolute()}")
                exe_path.chmod(0o755)
                
                # Probar el ejecutable
                print("🧪 Probando el ejecutable...")
                test_result = subprocess.run(
                    [str(exe_path), "--help"],
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                
                if test_result.returncode == 0:
                    print("✅ Ejecutable funciona correctamente")
                    print("📋 Salida de --help:")
                    print(test_result.stdout)
                else:
                    print("⚠️  Ejecutable generado pero no funciona correctamente")
                    print(f"Error: {test_result.stderr}")
            else:
                print("❌ Ejecutable no encontrado")
                print("📁 Contenido del directorio dist:")
                if Path("dist").exists():
                    for item in Path("dist").iterdir():
                        print(f"  - {item}")
                else:
                    print("  (directorio dist no existe)")
        else:
            print("❌ PyInstaller falló")
            
    except subprocess.TimeoutExpired:
        print("❌ Timeout: PyInstaller tardó demasiado")
    except Exception as e:
        print(f"❌ Error inesperado: {e}")

if __name__ == "__main__":
    main() 