from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from app.models import MeetingNoticeRequest
from app.pdf_generator import PDFGenerator
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Meeting Notice PDF Generator API",
    description="API para generar PDFs de convocatorias de reuniones usando WeasyPrint",
    version="1.0.0"
)

# Initialize PDF generator
pdf_generator = PDFGenerator()


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "Meeting Notice PDF Generator API",
        "version": "1.0.0",
        "status": "running"
    }


@app.post("/meeting-notice/generate-pdf")
async def generate_meeting_notice_pdf(request: MeetingNoticeRequest):
    """
    Genera un PDF de convocatoria de reunión basado en los datos proporcionados.
    
    Args:
        request: Datos de la convocatoria de reunión
        
    Returns:
        PDF file como respuesta HTTP
    """
    try:
        logger.info(f"Generating PDF for meeting ID: {request.meeting.id}")
        
        # Generate PDF
        pdf_bytes = pdf_generator.generate_meeting_notice_pdf(request)
        
        logger.info(f"PDF generated successfully for meeting ID: {request.meeting.id}")
        
        # Return PDF as response
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f"attachment; filename=convocatoria_reunion_{request.meeting.id}.pdf"
            }
        )
        
    except Exception as e:
        logger.error(f"Error generating PDF for meeting ID {request.meeting.id}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error generando el PDF: {str(e)}"
        )


@app.api_route("/health", methods=["GET", "HEAD"])
async def health_check():
    """Health check endpoint for monitoring"""
    return {
        "status": "healthy",
        "service": "meeting-notice-pdf-generator",
        "version": "1.0.0"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 