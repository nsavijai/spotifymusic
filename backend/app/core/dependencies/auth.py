from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.security.jwt_handler import verify_token

_bearer = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> dict:
    """
    Extract and verify the JWT Bearer token from the Authorization header.
    Returns the decoded token payload as a dict with at least {'sub': user_id}.
    Raises HTTP 401 if the token is missing or invalid.
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={'message': 'Authorization header missing', 'error_code': 'unauthorized'},
            headers={'WWW-Authenticate': 'Bearer'},
        )
    try:
        payload = verify_token(credentials.credentials)
        return payload
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={'message': 'Invalid or expired token', 'error_code': 'invalid_token'},
            headers={'WWW-Authenticate': 'Bearer'},
        )
