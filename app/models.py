from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum


class VoteType(str, Enum):
    SIMPLE = "simple"
    APPROVAL = "approval"
    MULTIPLE = "multiple"
    MULTIPLE_CHOICE = "multiple_choice"
    FREE = "free"
    DISCUSSION = "discussion"


class Coordinates(BaseModel):
    Lat: float
    Long: float


class Admin(BaseModel):
    cif: str
    company: str
    email: str
    name: str
    phone: str


class Community(BaseModel):
    address: str
    admin: Optional[Admin] = None
    cif: str
    coordinates: Coordinates
    id: str
    name: str


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
    vote_type: VoteType
    majority_type: Optional[str] = None
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


class Meeting(BaseModel):
    id: str
    date_time: int  # Unix timestamp
    description: str
    documents: List[Document] = []
    location: str
    meeting_points: List[MeetingPoint] = []
    meeting_type: str  # ORDINARY or EXTRAORDINARY
    status: int
    title: str


class MeetingNoticeRequest(BaseModel):
    community: Community
    meeting: Meeting 