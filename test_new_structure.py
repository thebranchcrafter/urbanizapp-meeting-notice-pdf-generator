#!/usr/bin/env python3
"""
Test script for the new request structure
"""

import json
from app.models import MeetingNoticeRequest
from app.pdf_generator import PDFGenerator

def test_new_structure():
    # Sample data matching the new structure
    sample_data = {
        "community": {
            "address": "Calle de Albarracín, 33, Madrid, España",
            "admin": {
                "cif": "B5423423432",
                "company": "Seroanda",
                "email": "ana.seroanda@test.com",
                "is_internal": False,
                "name": "Ana Pérez",
                "phone": "+34333333333"
            },
            "cif": "B12345676",
            "coordinates": {
                "Lat": 40.432658,
                "Long": -3.6310267
            },
            "id": "01K1C1TN9A7JNZP6YMNVWJCHQ1",
            "legal_name": "Nombre legal comunidad",
            "name": "Nombre comunidad"
        },
        "meeting": {
            "date_time": 1753919400000,
            "description": "dadasd",
            "documents": [
                {
                    "content_type": "application/pdf",
                    "id": "01K1C2MRH1XP8XEXH0TY2J8XKA",
                    "name": "es.aeat.dit.adu.eeca.catalogo.vis.pdf",
                    "signed_url": "",
                    "size": 220154
                }
            ],
            "id": "01K1C2MRFPSEW1DGB4JB3XG7FB",
            "location": "adada",
            "meeting_points": [
                {
                    "created_at": "2025-07-29T21:50:39Z",
                    "description": "dasdasdsa",
                    "documents": [],
                    "id": "01K1C2N1YRAH9WBTZQPNB4QEMH",
                    "meeting_id": "01K1C2MRFPSEW1DGB4JB3XG7FB",
                    "title": "asdas",
                    "updated_at": "2025-07-29T21:50:39Z",
                    "voting": {
                        "options": [
                            {
                                "id": "yes",
                                "option": "Sí",
                                "order": 1
                            },
                            {
                                "id": "no",
                                "option": "No",
                                "order": 2
                            }
                        ],
                        "voteType": "simple"
                    }
                }
            ],
            "meeting_type": "ORDINARY",
            "status": 1,
            "title": "asdasdasd"
        }
    }

    try:
        # Parse the data using the new model
        request = MeetingNoticeRequest(**sample_data)
        print("✅ Data parsed successfully!")
        print(f"Community: {request.community.name}")
        print(f"Meeting: {request.meeting.title}")
        print(f"Meeting type: {request.meeting.meeting_type}")
        print(f"Admin: {request.community.admin.name if request.community.admin else 'None'}")
        
        # Generate PDF
        generator = PDFGenerator()
        pdf_bytes = generator.generate_meeting_notice_pdf(request)
        
        # Save PDF
        with open("test_new_structure.pdf", "wb") as f:
            f.write(pdf_bytes)
        
        print("✅ PDF generated successfully!")
        print("📄 PDF saved as 'test_new_structure.pdf'")
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_new_structure() 