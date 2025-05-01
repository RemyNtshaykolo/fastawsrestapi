from fastapi.openapi.models import OAuthFlows as OAuthFlowsModel
import jwt
from fastapi.security import APIKeyHeader, OAuth2
from fastapi import Request, HTTPException
from typing import Optional
from fastapi.security.utils import get_authorization_scheme_param


class Oauth2ClientCredentials(OAuth2):
    def __init__(
        self,
        tokenUrl: str,
        scheme_name: str = "Oauth2ClientCredentials",
        scopes: dict = None,
        auto_error: bool = True,
    ):
        if not scopes:
            scopes = {}
        flows = OAuthFlowsModel(
            clientCredentials={"tokenUrl": tokenUrl, "scopes": scopes}
        )
        super().__init__(flows=flows, scheme_name=scheme_name, auto_error=auto_error)

    async def __call__(self, request: Request) -> Optional[str]:
        authorization: str = request.headers.get("Authorization")
        scheme, param = get_authorization_scheme_param(authorization)
        if not authorization or scheme.lower() != "bearer":
            if self.auto_error:
                raise HTTPException(
                    status_code=401,
                    detail="Not authenticated",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            else:
                return None
        return param


# Configuration de l'authentification
api_key_header = APIKeyHeader(
    name="x-api-key", auto_error=True, scheme_name="APIKeyHeader"
)


oauth2_scheme = Oauth2ClientCredentials(tokenUrl="default/token")


auth_responses = {
    403: {
        "description": "Forbidden",
        "content": {
            "application/json": {
                "schema": {
                    "type": "object",
                    "properties": {"message": {"type": "string"}},
                },
                "example": {"message": "Forbidden"},
            }
        },
    }
}


def get_user_id(token: str):
    # No need to verify signature because Api gateway already did it.
    payload = jwt.decode(token, options={"verify_signature": False})
    cognito_client_id = payload["sub"]
    return cognito_client_id
