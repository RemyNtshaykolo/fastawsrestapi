from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional
import base64
import requests
import os
from fastapi import Header, Query

auth_router = APIRouter(tags=["auth"])


class TokenInput(BaseModel):
    client_id: str
    client_secret: str


def get_credentials_from_swagger_auth(
    authorization: Optional[str] = Header(None, include_in_schema=False)
):
    """
    This is only used when calling the API from Swagger UI using OAuth2
    (i.e., SwaggerUI Authentication).
    """
    if authorization and authorization.startswith("Basic "):
        try:
            token = authorization[6:]
            decoded = base64.b64decode(token).decode("utf-8")
            client_id, client_secret = decoded.split(":", 1)
            return TokenInput(client_id=client_id, client_secret=client_secret)
        except Exception:
            raise HTTPException(
                status_code=401, detail="Malformed SwaggerUI Authorization header"
            )
    return None


@auth_router.post(
    "/token",
    openapi_extra={
        "x-conf": {
            "caching": {
                "enabled": True,
                "maxTtl": 3600,
                "keys": {"header": ["Authorization"], "query": ["scope"]},
            }
        },
    },
    description="""Get a token to access the API from Swagger UI.
    
The Authorization header must be in the format: 'Basic <base64_encoded_credentials>'
where <base64_encoded_credentials> is the base64 encoding of 'client_id:client_secret'.

Example:
- If client_id is 'my_client' and client_secret is 'my_secret'
- First concatenate with colon: 'my_client:my_secret'
- Then base64 encode: 'bXlfY2xpZW50Om15X3NlY3JldA=='
- Final header value: 'Basic bXlfY2xpZW50Om15X3NlY3JldA=='
""",
)
async def get_token(
    scope: str = Query(None),
    Authorization: str = Header(
        ...,
        description="Authorization header in Basic auth format with base64 encoded client_id:client_secret",
    ),
):
    credentials = get_credentials_from_swagger_auth(Authorization)
    client_id = credentials.client_id
    client_secret = credentials.client_secret
    # Request to Cognito
    resp = requests.post(
        os.environ["COGNITO_ENDPOINT"],
        data={
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
            "scope": scope,
        },
    )
    return resp.json()
