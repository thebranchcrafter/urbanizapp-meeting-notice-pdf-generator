#!/usr/bin/env python3
"""
Script de prueba para generar un PDF de ejemplo con el nuevo diseño
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.pdf_generator import PDFGenerator
from app.models import (
    MeetingNoticeRequest, 
    MeetingPoint, 
    Document, 
    Voting, 
    VotingOption, 
    MeetingNoticeFile,
    VoteType
)
from datetime import datetime
import time

def create_sample_data():
    """Crear datos de ejemplo para la prueba"""
    
    # Crear documentos de ejemplo
    documents = [
        Document(
            id="doc1",
            name="Presupuesto 2024.pdf",
            signed_url="https://example.com/doc1.pdf",
            content_type="application/pdf",
            size=1024000
        ),
        Document(
            id="doc2",
            name="Acta anterior.pdf",
            signed_url="https://example.com/doc2.pdf",
            content_type="application/pdf",
            size=512000
        )
    ]
    
    # Crear opciones de votación
    voting_options = [
        VotingOption(id="opt1", option="Opción A: Renovar contrato actual", order=1),
        VotingOption(id="opt2", option="Opción B: Buscar nuevo proveedor", order=2),
        VotingOption(id="opt3", option="Opción C: Mantener situación actual", order=3)
    ]
    
    # Crear puntos de reunión
    meeting_points = [
        MeetingPoint(
            id="point1",
            meeting_id="meeting123",
            title="Aprobación del presupuesto anual 2024",
            description="Se somete a votación la aprobación del presupuesto anual para el ejercicio 2024, que incluye los gastos de mantenimiento, limpieza y administración de la comunidad.",
            documents=[documents[0]],
            voting=Voting(voteType=VoteType.APPROVAL, options=[]),
            created_at=datetime.now(),
            updated_at=datetime.now()
        ),
        MeetingPoint(
            id="point2",
            meeting_id="meeting123",
            title="Renovación del contrato de limpieza",
            description="Se debe decidir sobre la renovación del contrato de servicios de limpieza que finaliza el próximo mes. Se presentan tres opciones para la consideración de los propietarios.",
            documents=[],
            voting=Voting(voteType=VoteType.MULTIPLE_CHOICE, options=voting_options),
            created_at=datetime.now(),
            updated_at=datetime.now()
        ),
        MeetingPoint(
            id="point3",
            meeting_id="meeting123",
            title="Instalación de sistema de seguridad",
            description="Se propone la instalación de un sistema de videovigilancia en las zonas comunes. Este punto requiere discusión previa a la votación.",
            documents=[],
            voting=Voting(voteType=VoteType.DISCUSSION, options=[]),
            created_at=datetime.now(),
            updated_at=datetime.now()
        )
    ]
    
    # Crear archivo de convocatoria
    meeting_notice_file = MeetingNoticeFile(
        id="notice1",
        name="Convocatoria oficial.pdf",
        signed_url="https://example.com/notice.pdf",
        content_type="application/pdf",
        size=256000
    )
    
    # Crear la solicitud de reunión
    meeting_request = MeetingNoticeRequest(
        id="meeting123",
        community_id="CP123456",
        title="Junta General Ordinaria",
        meeting_type="ordinaria",
        date_time=int(time.time()) + 86400,  # Mañana
        location="Restaurante Nuevo Zulema",
        description="Se convoca a todos los propietarios a la Junta General Ordinaria para tratar los asuntos del orden del día.",
        status=1,
        documents=documents,
        meeting_notice_file=meeting_notice_file,
        meeting_points=meeting_points
    )
    
    return meeting_request

def main():
    """Función principal"""
    print("🚀 Generando PDF de prueba con el nuevo diseño...")
    
    try:
        # Crear datos de ejemplo
        sample_data = create_sample_data()
        
        # Crear generador de PDF
        pdf_generator = PDFGenerator()
        
        # Generar PDF
        print("📄 Generando PDF...")
        pdf_bytes = pdf_generator.generate_meeting_notice_pdf(sample_data)
        
        # Guardar PDF
        output_file = "test_meeting_notice.pdf"
        with open(output_file, "wb") as f:
            f.write(pdf_bytes)
        
        print(f"✅ PDF generado exitosamente: {output_file}")
        print(f"📊 Tamaño del archivo: {len(pdf_bytes)} bytes")
        
        # Mostrar información del PDF
        print("\n📋 Información del PDF generado:")
        print(f"   - Título: {sample_data.title}")
        print(f"   - ID de reunión: {sample_data.id}")
        print(f"   - Comunidad: {sample_data.community_id}")
        print(f"   - Puntos de reunión: {len(sample_data.meeting_points)}")
        print(f"   - Documentos adjuntos: {len(sample_data.documents)}")
        
        print("\n🎨 Características del nuevo diseño:")
        print("   - Fuente moderna (Segoe UI/Roboto)")
        print("   - Colores profesionales")
        print("   - Casillas de votación modernizadas")
        print("   - Hoja de votación separada")
        print("   - Formato legal mejorado")
        
    except Exception as e:
        print(f"❌ Error generando PDF: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main() 