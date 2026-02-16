from pydantic import BaseModel, Field
from typing import Optional

class CategorizeRequest(BaseModel):
    description: str = Field(..., min_length=1, examples=["STARBUCKS 1287 WILMINGTON NC"])
    amount: Optional[float] = Field(None, examples=[7.45])


class CategorizeResponse(BaseModel):
    category: str
    confidence: float
    method: str
