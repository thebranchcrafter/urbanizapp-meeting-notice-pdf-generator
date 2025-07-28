FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Instalar dependencias del sistema necesarias para WeasyPrint
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    shared-mime-info \
    wget \
 && apt-get purge -y --auto-remove \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

# Copiar solo requirements.txt primero para aprovechar la caché de Docker
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Crear directorios necesarios
RUN mkdir -p /app/app /app/app/templates /app/app/static

# Copiar archivos estáticos y templates desde app/ (estos no cambian frecuentemente)
COPY app/templates/ /app/app/templates/
COPY app/static/ /app/app/static/

# El código de la aplicación se montará como volumen en desarrollo
# COPY . .

EXPOSE 8000

# Usar uvicorn con reload para desarrollo
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
