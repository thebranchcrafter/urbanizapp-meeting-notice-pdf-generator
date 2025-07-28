from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum


class VoteType(str, Enum):
    APPROVAL = "approval"
    MULTIPLE_CHOICE = "multiple_choice"
    DISCUSSION = "discussion"


class Document(BaseModel):
    id: str
    name: str
    signed_url: str
    content_type: str
    size: int


class VotingOption(BaseModel):
    id: str
    option: str
    order: int


class Voting(BaseModel):
    voteType: VoteType
    options: List[VotingOption] = []


class MeetingPoint(BaseModel):
    id: str
    meeting_id: str
    title: str
    description: str
    documents: List[Document] = []
    voting: Voting
    created_at: datetime
    updated_at: datetime


class MeetingNoticeFile(BaseModel):
    id: str
    name: str
    signed_url: str
    content_type: str
    size: int


class MeetingNoticeRequest(BaseModel):
    id: str
    community_id: str
    title: str
    meeting_type: str
    date_time: int  # Unix timestamp
    location: str
    description: str
    status: int
    documents: List[Document] = []
    meeting_notice_file: Optional[MeetingNoticeFile] = None
    meeting_points: List[MeetingPoint] = [] 