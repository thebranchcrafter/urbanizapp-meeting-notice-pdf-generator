import os
from datetime import datetime
from typing import List
from weasyprint import HTML, CSS
from jinja2 import Template
from app.models import MeetingNoticeRequest, MeetingPoint, Document
import logging

class PDFGenerator:
    def __init__(self):
        self.template_dir = os.path.join(os.path.dirname(__file__), 'templates')
        self.static_dir = os.path.join(os.path.dirname(__file__), 'static')
        
    def _load_template(self, template_name: str) -> Template:
        """Load HTML template from file"""
        template_path = os.path.join(self.template_dir, template_name)
        with open(template_path, 'r', encoding='utf-8') as f:
            return Template(f.read())
    
    def _load_css(self, css_name: str) -> str:
        """Load CSS from file"""
        css_path = os.path.join(self.static_dir, css_name)
        with open(css_path, 'r', encoding='utf-8') as f:
            return f.read()
    
    def _format_datetime(self, timestamp: int) -> str:
        """Convert Unix timestamp to formatted datetime string"""
        dt = datetime.fromtimestamp(timestamp / 1000)  # Convert from milliseconds
        return dt.strftime("%d de %B de %Y")
    
    def _format_time(self, timestamp: int) -> str:
        """Convert Unix timestamp to formatted time string"""
        dt = datetime.fromtimestamp(timestamp / 1000)  # Convert from milliseconds
        return dt.strftime("%H:%M")
    
    def _format_location_time(self, timestamp: int) -> str:
        """Format timestamp for location and time in legal format"""
        dt = datetime.fromtimestamp(timestamp / 1000)  # Convert from milliseconds
        # Add 30 minutes for second call using timedelta for proper time arithmetic
        from datetime import timedelta
        second_call = dt + timedelta(minutes=30)
        
        return f"{dt.strftime('%H:%M')} horas en primera convocatoria, y a las {second_call.strftime('%H:%M')} horas en segunda convocatoria"
    
    def _format_file_size(self, size_bytes: int) -> str:
        """Convert bytes to human readable format"""
        if size_bytes < 1024:
            return f"{size_bytes} B"
        elif size_bytes < 1024 * 1024:
            return f"{size_bytes / 1024:.1f} KB"
        else:
            return f"{size_bytes / (1024 * 1024):.1f} MB"
    
    def _get_vote_type_text(self, vote_type: str) -> str:
        """Get human readable text for vote type"""
        vote_types = {
            "simple": "Simple",
            "approval": "Aprobación",
            "multiple": "Opción múltiple",
            "multiple_choice": "Opción múltiple",
            "free": "Texto libre",
            "discussion": "Discusión"
        }
        return vote_types.get(vote_type, vote_type)
    
    def _get_majority_type_text(self, majority_type: str) -> str:
        """Get human readable text for majority type"""
        majority_types = {
            "simple_attendees": "Mayoría simple de asistentes",
            "absolute_attendees": "Mayoría absoluta de asistentes",
            "simple_quorum": "Mayoría simple del quórum",
            "absolute_quorum": "Mayoría absoluta del quórum",
            "qualified": "Mayoría cualificada"
        }
        return majority_types.get(majority_type, majority_type)
    
    def _get_location_with_article(self, location: str) -> str:
        """Add appropriate article (el/la) to location"""
        if not location:
            return ""
        location_lower = location.lower().strip()
        # Common patterns that use "la"
        la_patterns = ["sala", "casa", "oficina", "residencia", "plaza", "calle"]
        # Common patterns that use "el"
        el_patterns = ["edificio", "local", "salón", "centro", "pabellón"]
        
        # Check if location starts with any of these patterns
        for pattern in la_patterns:
            if location_lower.startswith(pattern):
                return f"la {location}"
        for pattern in el_patterns:
            if location_lower.startswith(pattern):
                return f"el {location}"
        
        # Default to "el" if unsure
        return f"el {location}"
    
    def _get_meeting_type_text(self, meeting_type: str) -> str:
        """Get human readable text for meeting type"""
        meeting_types = {
            "ORDINARY": "ORDINARIA",
            "EXTRAORDINARY": "EXTRAORDINARIA"
        }
        return meeting_types.get(meeting_type, meeting_type)
        
    def generate_meeting_notice_pdf(self, data: MeetingNoticeRequest) -> bytes:
        """
        Generate a PDF meeting notice using WeasyPrint
        
        Args:
            data: MeetingNoticeRequest object containing meeting data
            
        Returns:
            bytes: PDF content as bytes
        """
        try:
            # Load the HTML template
            template = self._load_template('meeting_notice.html')
            
            # Load CSS styles
            css_content = self._load_css('styles.css')
            
            # Prepare template context with properly formatted data
            context = {
                'community': {
                    'id': data.community.id,
                    'name': data.community.name,
                    'legal_name': getattr(data.community, 'legal_name', None),
                    'cif': data.community.cif,
                    'address': data.community.address,
                    'coordinates': data.community.coordinates,
                    'admin': data.community.admin
                },
                'meeting': {
                    'id': data.meeting.id,
                    'title': data.meeting.title,
                    'community_name': data.community.name,
                    'meeting_type': self._get_meeting_type_text(data.meeting.meeting_type),
                    'meeting_type_translated': self._get_meeting_type_text(data.meeting.meeting_type).lower(),
                    'date_time': self._format_datetime(data.meeting.date_time),
                    'time': self._format_time(data.meeting.date_time),
                    'location_time': self._format_location_time(data.meeting.date_time),
                    'location': data.meeting.location,
                    'location_with_article': self._get_location_with_article(data.meeting.location),
                    'description': data.meeting.description,
                    'status': data.meeting.status,
                    'documents': data.meeting.documents,
                    'meeting_points': data.meeting.meeting_points
                },
                'generated_at': datetime.now().strftime("%d/%m/%Y a las %H:%M horas"),
                'format_file_size': self._format_file_size,
                'get_vote_type_text': self._get_vote_type_text,
                'get_majority_type_text': self._get_majority_type_text
            }
            
            # Render HTML with template
            html_content = template.render(**context)
            
            # Create WeasyPrint HTML object
            html_doc = HTML(string=html_content)
            
            # Create CSS object
            css_doc = CSS(string=css_content)
            
            # Generate PDF with styles
            pdf_bytes = html_doc.write_pdf(stylesheets=[css_doc])
            
            return pdf_bytes
            
        except Exception as e:
            logging.error(f"Error generating PDF: {str(e)}")
            raise Exception(f"Failed to generate PDF: {str(e)}")