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
        # Add 30 minutes for second call
        second_call = dt.replace(minute=dt.minute + 30)
        if second_call.minute >= 60:
            second_call = second_call.replace(hour=second_call.hour + 1, minute=second_call.minute - 60)
        
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
            "approval": "Aprobación",
            "multiple_choice": "Opción múltiple",
            "discussion": "Discusión",
            "simple": "Simple"
        }
        return vote_types.get(vote_type, vote_type)
    
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
                    'legal_name': data.community.legal_name,
                    'cif': data.community.cif,
                    'address': data.community.address,
                    'coordinates': data.community.coordinates,
                    'admin': data.community.admin
                },
                'meeting': {
                    'id': data.meeting.id,
                    'title': data.meeting.title,
                    'meeting_type': self._get_meeting_type_text(data.meeting.meeting_type),
                    'date_time': self._format_datetime(data.meeting.date_time),
                    'time': self._format_time(data.meeting.date_time),
                    'location_time': self._format_location_time(data.meeting.date_time),
                    'location': data.meeting.location,
                    'description': data.meeting.description,
                    'status': data.meeting.status,
                    'documents': data.meeting.documents,
                    'meeting_points': data.meeting.meeting_points
                },
                'generated_at': datetime.now().strftime("%d/%m/%Y a las %H:%M horas"),
                'format_file_size': self._format_file_size,
                'get_vote_type_text': self._get_vote_type_text
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