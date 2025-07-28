#!/usr/bin/env python3
"""
Script de ejemplo para probar la API de generación de PDFs
"""

import requests
import json
from datetime import datetime

# URL de la API (ajusta según tu configuración)
API_BASE_URL = "http://localhost:8000"

def test_health_check():
    """Prueba el endpoint de health check"""
    print("🔍 Probando health check...")
    try:
        response = requests.get(f"{API_BASE_URL}/health")
        if response.status_code == 200:
            print("✅ Health check exitoso")
            print(f"   Respuesta: {response.json()}")
        else:
            print(f"❌ Health check falló: {response.status_code}")
    except requests.exceptions.ConnectionError:
        print("❌ No se pudo conectar a la API. Asegúrate de que esté ejecutándose.")
        return False
    return True

def test_pdf_generation():
    """Prueba la generación de PDF"""
    print("\n📄 Probando generación de PDF...")
    
    # Datos de ejemplo para la convocatoria
    meeting_data = {
        "id": "01HXYZ123456789ABCDEF",
        "community_id": "01HXYZ987654321FEDCBA",
        "title": "Reunión ordinaria de la Comunidad",
        "meeting_type": "ordinary",
        "date_time": 1704067200,
        "location": "Centro Comunitario Principal",
        "description": "Reunión mensual para discutir temas importantes de la comunidad y planificar actividades futuras.",
        "status": 1,
        "documents": [
            {
                "id": "01HXYZ111111111111111",
                "name": "agenda_reunion_enero.pdf",
                "signed_url": "https://example-bucket.s3.amazonaws.com/documents/agenda_reunion_enero.pdf?signature=abc123",
                "content_type": "application/pdf",
                "size": 245760
            },
            {
                "id": "01HXYZ222222222222222",
                "name": "minutas_diciembre.pdf",
                "signed_url": "https://example-bucket.s3.amazonaws.com/documents/minutas_diciembre.pdf?signature=def456",
                "content_type": "application/pdf",
                "size": 189440
            }
        ],
        "meeting_notice_file": {
            "id": "01HXYZ333333333333333",
            "name": "convocatoria_reunion.pdf",
            "signed_url": "https://example-bucket.s3.amazonaws.com/documents/convocatoria_reunion.pdf?signature=ghi789",
            "content_type": "application/pdf",
            "size": 156672
        },
        "meeting_points": [
            {
                "id": "01HXYZ444444444444444",
                "meeting_id": "01HXYZ123456789ABCDEF",
                "title": "Revisión del Presupuesto Anual",
                "description": "Discutir y aprobar el presupuesto para el próximo año fiscal",
                "documents": [
                    {
                        "id": "01HXYZ555555555555555",
                        "name": "presupuesto_2024.xlsx",
                        "signed_url": "https://example-bucket.s3.amazonaws.com/documents/presupuesto_2024.xlsx?signature=jkl012",
                        "content_type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        "size": 456320
                    }
                ],
                "voting": {
                    "voteType": "approval",
                    "options": [
                        {
                            "id": "01HXYZ666666666666666",
                            "option": "Aprobar",
                            "order": 1
                        },
                        {
                            "id": "01HXYZ777777777777777",
                            "option": "Rechazar",
                            "order": 2
                        },
                        {
                            "id": "01HXYZ888888888888888",
                            "option": "Aprobar con modificaciones",
                            "order": 3
                        }
                    ]
                },
                "created_at": "2024-01-15T10:30:00Z",
                "updated_at": "2024-01-15T10:30:00Z"
            },
            {
                "id": "01HXYZ999999999999999",
                "meeting_id": "01HXYZ123456789ABCDEF",
                "title": "Elección de Nuevos Miembros del Comité",
                "description": "Votar por los nuevos miembros que se integrarán al comité directivo",
                "documents": [
                    {
                        "id": "01HXYZAAAAAAAAAAAAAAA",
                        "name": "candidatos_comite.pdf",
                        "signed_url": "https://example-bucket.s3.amazonaws.com/documents/candidatos_comite.pdf?signature=mno345",
                        "content_type": "application/pdf",
                        "size": 321024
                    }
                ],
                "voting": {
                    "voteType": "multiple_choice",
                    "options": [
                        {
                            "id": "01HXYZBBBBBBBBBBBBBBB",
                            "option": "María González",
                            "order": 1
                        },
                        {
                            "id": "01HXYZCCCCCCCCCCCCCCC",
                            "option": "Carlos Rodríguez",
                            "order": 2
                        },
                        {
                            "id": "01HXYZDDDDDDDDDDDDDDD",
                            "option": "Ana Martínez",
                            "order": 3
                        },
                        {
                            "id": "01HXYZEEEEEEEEEEEEEEE",
                            "option": "Luis Pérez",
                            "order": 4
                        }
                    ]
                },
                "created_at": "2024-01-15T10:35:00Z",
                "updated_at": "2024-01-15T10:35:00Z"
            },
            {
                "id": "01HXYZFFFFFFFFFFFFFFF",
                "meeting_id": "01HXYZ123456789ABCDEF",
                "title": "Planificación de Eventos Comunitarios",
                "description": "Definir el calendario de eventos para los próximos 6 meses",
                "documents": [],
                "voting": {
                    "voteType": "discussion",
                    "options": []
                },
                "created_at": "2024-01-15T10:40:00Z",
                "updated_at": "2024-01-15T10:40:00Z"
            }
        ]
    }
    
    try:
        # Enviar solicitud para generar PDF
        response = requests.post(
            f"{API_BASE_URL}/meeting-notice/generate-pdf",
            json=meeting_data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            print("✅ PDF generado exitosamente")
            
            # Guardar el PDF
            filename = f"convocatoria_reunion_{meeting_data['id']}.pdf"
            with open(filename, "wb") as f:
                f.write(response.content)
            
            print(f"📁 PDF guardado como: {filename}")
            print(f"📊 Tamaño del archivo: {len(response.content)} bytes")
            
            return True
        else:
            print(f"❌ Error generando PDF: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error de conexión: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 Iniciando pruebas de la API de generación de PDFs")
    print("=" * 50)
    
    # Probar health check
    if not test_health_check():
        print("\n❌ La API no está disponible. Ejecuta la aplicación primero:")
        print("   python -m app.main")
        print("   o")
        print("   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload")
        return
    
    # Probar generación de PDF
    test_pdf_generation()
    
    print("\n" + "=" * 50)
    print("✨ Pruebas completadas")
    print("\n📚 Recursos adicionales:")
    print("   - Documentación de la API: http://localhost:8000/docs")
    print("   - Health check: http://localhost:8000/health")

if __name__ == "__main__":
    main() 