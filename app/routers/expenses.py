from datetime import datetime
from enum import Enum
from fastapi import APIRouter, HTTPException, status

from dependencies import SessionDep

currentYear = datetime.now().year

router = APIRouter(
    prefix="/expenses",
    tags=["expenses"]
)

class EnsembleExpenseType(str, Enum):
    admin = "admin"
    award = "award"
    reimbursement = "reimbursement"
    rental = "rental"
    advertisement = "advertisment"
    appreciation = "appreciation"

@router.get("/{expenseType}")
async def getExpenses(expenseType: EnsembleExpenseType, year: int = currentYear):
    if expenseType is EnsembleExpenseType.admin:
        return ({"message": f"These are administrative expenses for the year {year}"})

