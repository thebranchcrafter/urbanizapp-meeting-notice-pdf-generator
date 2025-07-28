#!/usr/bin/env python3
"""
CLI tool for generating meeting notice PDFs from JSON data.
Usage: python -m app.cli --json-file data.json --output output.pdf
"""

import argparse
import json
import sys
import os
from pathlib import Path
from app.models import MeetingNoticeRequest
from app.pdf_generator import PDFGenerator
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def load_json_data(json_file: str) -> dict:
    """Load JSON data from file or stdin"""
    try:
        if json_file == '-':
            # Read from stdin
            data = json.load(sys.stdin)
        else:
            # Read from file
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
        return data
    except json.JSONDecodeError as e:
        logger.error(f"Error parsing JSON: {e}")
        sys.exit(1)
    except FileNotFoundError:
        logger.error(f"File not found: {json_file}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error reading JSON data: {e}")
        sys.exit(1)


def validate_data(data: dict) -> bool:
    """Basic validation of required fields"""
    required_fields = ['id', 'community_id', 'title', 'meeting_type', 'date_time', 'location', 'description', 'status']
    
    for field in required_fields:
        if field not in data:
            logger.error(f"Missing required field: {field}")
            return False
    
    return True


def generate_pdf_from_json(json_data: dict, output_file: str) -> bool:
    """Generate PDF from JSON data"""
    try:
        # Validate data
        if not validate_data(json_data):
            return False
        
        # Create MeetingNoticeRequest object
        meeting_request = MeetingNoticeRequest(**json_data)
        
        # Initialize PDF generator
        pdf_generator = PDFGenerator()
        
        # Generate PDF
        logger.info(f"Generating PDF for meeting ID: {meeting_request.id}")
        pdf_bytes = pdf_generator.generate_meeting_notice_pdf(meeting_request)
        
        # Write to output file
        with open(output_file, 'wb') as f:
            f.write(pdf_bytes)
        
        logger.info(f"PDF generated successfully: {output_file}")
        return True
        
    except Exception as e:
        logger.error(f"Error generating PDF: {e}")
        return False


def main():
    """Main CLI function"""
    parser = argparse.ArgumentParser(
        description="Generate meeting notice PDF from JSON data",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate PDF from JSON file
  python -m app.cli --json-file data.json --output meeting_notice.pdf
  
  # Generate PDF from stdin
  cat data.json | python -m app.cli --json-file - --output meeting_notice.pdf
  
  # Generate PDF with custom filename based on meeting ID
  python -m app.cli --json-file data.json --output-dir ./pdfs/
        """
    )
    
    parser.add_argument(
        '--json-file', '-j',
        required=True,
        help='JSON file with meeting data (use "-" for stdin)'
    )
    
    parser.add_argument(
        '--output', '-o',
        help='Output PDF file path'
    )
    
    parser.add_argument(
        '--output-dir', '-d',
        help='Output directory (filename will be auto-generated based on meeting ID)'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose logging'
    )
    
    args = parser.parse_args()
    
    # Set logging level
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Load JSON data
    json_data = load_json_data(args.json_file)
    
    # Determine output file
    if args.output:
        output_file = args.output
    elif args.output_dir:
        # Auto-generate filename based on meeting ID
        meeting_id = json_data.get('id', 'unknown')
        output_dir = Path(args.output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        output_file = output_dir / f"convocatoria_reunion_{meeting_id}.pdf"
    else:
        # Default output to current directory
        meeting_id = json_data.get('id', 'unknown')
        output_file = f"convocatoria_reunion_{meeting_id}.pdf"
    
    # Generate PDF
    success = generate_pdf_from_json(json_data, str(output_file))
    
    if success:
        logger.info(f"PDF generated successfully: {output_file}")
        sys.exit(0)
    else:
        logger.error("Failed to generate PDF")
        sys.exit(1)


if __name__ == "__main__":
    main() 