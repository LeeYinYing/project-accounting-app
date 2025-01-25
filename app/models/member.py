from enum import Enum
from sqlmodel import SQLModel, Field as SQLField
from pydantic import EmailStr, Field

class MemberType(str, Enum):
    performer = "performer"
    volunteer = "volunteer"

class MemberBase(SQLModel):
    name: str = Field(index=True)
    active: bool = True
    type: MemberType = Field(
        examples = ["performer", "volunteer"], 
        default="performer"
    )
    phone: str | None = Field(
        pattern="^[0-9]{3}-[0-9]{3}-[0-9]{4}", 
        examples=["403-888-1234"],
        default = None
    )
    email: EmailStr | None = Field(
        examples=["annali@guzhengcalgary.ca"], 
        default=None
    )
    address: str | None = Field(
        pattern="^.*, .*, [A-Z]{2}, [A-Z][0-9][A-Z]\s[0-9][A-Z][0-9]$",
        examples=["122 FaCai Street E, Calgary, AB, A1B 2C3"],
        default=None
    )

class Member(MemberBase, table=True):
    id: int | None = SQLField(default=None, primary_key=True)

class MemberPublic(MemberBase):
    id: int

class MemberUpdate(MemberBase):
    name: str | None = None
    active: bool | None = None
    type: MemberType | None = None
