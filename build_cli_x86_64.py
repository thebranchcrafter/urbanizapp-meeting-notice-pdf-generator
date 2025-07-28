#!/usr/bin/env python3
"""
Script para generar el ejecutable CLI para x86_64 Ubuntu.
"""

import os
import sys
import subprocess

def main():
    """Generar ejecutable para x86_64"""
    print("🔨 Generando ejecutable x86_64...")
    
    # Configurar variables de entorno
    os.environ['PYTHONPATH'] = os.getcwd()
    os.environ['WEASYPRINT_NO_SANDBOX'] = '1'
    os.environ['CHROME_NO_SANDBOX'] = '1'
    
    # Comando PyInstaller específico para x86_64
    cmd = [
        'python3', '-m', 'PyInstaller',
        '--onefile', '--console', '--clean', '--noconfirm',
        '--distpath', 'dist/x86_64',
        '--add-data', 'app/templates:app/templates',
        '--add-data', 'app/static:app/static',
        '--hidden-import', 'weasyprint', '--hidden-import', 'jinja2',
        '--hidden-import', 'pydantic', '--hidden-import', 'app.models',
        '--hidden-import', 'app.pdf_generator',
        '--exclude-module', 'tkinter', '--exclude-module', 'matplotlib',
        '--exclude-module', 'numpy', '--exclude-module', 'scipy',
        '--exclude-module', 'pandas', '--exclude-module', 'IPython',
        '--exclude-module', 'jupyter',
        '--name', 'meeting-notice-pdf-generator',
        'app/cli.py'
    ]
    
    try:
        subprocess.run(cmd, check=True)
        print("✅ PyInstaller completado para x86_64")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error en PyInstaller: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 