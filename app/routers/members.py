from fastapi import APIRouter, HTTPException, status

from models.member import *
from dependencies import SessionDep

router = APIRouter(
    prefix="/members",
    tags=["members"]
)

@router.post("/", response_model=MemberPublic, status_code=status.HTTP_201_CREATED)
async def addMember(member: MemberBase, session: SessionDep):
    memberDb = Member.model_validate(member)
    session.add(memberDb)
    session.commit()
    session.refresh(memberDb)
    return memberDb

@router.get("/{memberId}", response_model=MemberPublic)
async def getMember(memberId: int, session: SessionDep):
    member = session.get(Member, memberId)
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")
    return member

@router.patch("/{memberId}", response_model=MemberPublic)
async def updateMember(memberId: int, member: MemberUpdate, session: SessionDep):
    memberDb = session.get(Member, memberId)
    if not memberDb:
        raise HTTPException(status_code=404, detail="Member not found")
    memberData = member.model_dump(exclude_unset=True)
    memberDb.sqlmodel_update(memberData)
    session.add(memberDb)
    session.commit()
    session.refresh(memberDb)
    return memberDb

@router.delete("/{memberId}")
def deleteMember(memberId: int, session: SessionDep):
    member = session.get(Member, memberId)
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")
    session.delete(member)
    session.commit()
    return ({"ok": True})
