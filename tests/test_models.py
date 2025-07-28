import pytest
from datetime import datetime
from app.models import (
    MeetingNoticeRequest,
    Document,
    MeetingPoint,
    Voting,
    VotingOption,
    VoteType,
    MeetingNoticeFile
)


class TestModels:
    """Tests para los modelos Pydantic"""

    def test_document_model(self):
        """Test del modelo Document"""
        doc_data = {
            "id": "01HXYZ111111111111111",
            "name": "test.pdf",
            "signed_url": "https://example.com/test.pdf",
            "content_type": "application/pdf",
            "size": 1024
        }
        doc = Document(**doc_data)
        assert doc.id == doc_data["id"]
        assert doc.name == doc_data["name"]
        assert doc.signed_url == doc_data["signed_url"]
        assert doc.content_type == doc_data["content_type"]
        assert doc.size == doc_data["size"]

    def test_voting_option_model(self):
        """Test del modelo VotingOption"""
        option_data = {
            "id": "01HXYZ666666666666666",
            "option": "Aprobar",
            "order": 1
        }
        option = VotingOption(**option_data)
        assert option.id == option_data["id"]
        assert option.option == option_data["option"]
        assert option.order == option_data["order"]

    def test_voting_model(self):
        """Test del modelo Voting"""
        voting_data = {
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
                }
            ]
        }
        voting = Voting(**voting_data)
        assert voting.voteType == VoteType.APPROVAL
        assert len(voting.options) == 2
        assert voting.options[0].option == "Aprobar"
        assert voting.options[1].option == "Rechazar"

    def test_meeting_point_model(self):
        """Test del modelo MeetingPoint"""
        point_data = {
            "id": "01HXYZ444444444444444",
            "meeting_id": "01HXYZ123456789ABCDEF",
            "title": "Test Point",
            "description": "Test description",
            "documents": [],
            "voting": {
                "voteType": "discussion",
                "options": []
            },
            "created_at": "2024-01-15T10:30:00Z",
            "updated_at": "2024-01-15T10:30:00Z"
        }
        point = MeetingPoint(**point_data)
        assert point.id == point_data["id"]
        assert point.title == point_data["title"]
        assert point.voting.voteType == VoteType.DISCUSSION

    def test_meeting_notice_request_model(self):
        """Test del modelo MeetingNoticeRequest completo"""
        request_data = {
            "id": "01HXYZ123456789ABCDEF",
            "community_id": "01HXYZ987654321FEDCBA",
            "title": "Test Meeting",
            "meeting_type": "ordinary",
            "date_time": 1704067200,
            "location": "Test Location",
            "description": "Test description",
            "status": 1,
            "documents": [],
            "meeting_points": []
        }
        request = MeetingNoticeRequest(**request_data)
        assert request.id == request_data["id"]
        assert request.title == request_data["title"]
        assert request.meeting_type == request_data["meeting_type"]
        assert request.date_time == request_data["date_time"]

    def test_vote_type_enum(self):
        """Test del enum VoteType"""
        assert VoteType.APPROVAL == "approval"
        assert VoteType.MULTIPLE_CHOICE == "multiple_choice"
        assert VoteType.DISCUSSION == "discussion" 