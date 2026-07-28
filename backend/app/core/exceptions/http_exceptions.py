from fastapi import HTTPException, status


class ApiException(HTTPException):
    def __init__(self, status_code: int, message: str, error_code: str | None = None) -> None:
        self.error_code = error_code
        super().__init__(status_code=status_code, detail={'message': message, 'error_code': error_code})


class NotFoundException(ApiException):
    def __init__(self, message: str, error_code: str = 'not_found') -> None:
        super().__init__(status_code=status.HTTP_404_NOT_FOUND, message=message, error_code=error_code)


class ValidationException(ApiException):
    def __init__(self, message: str, error_code: str = 'validation_error') -> None:
        super().__init__(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, message=message, error_code=error_code)


class UnauthorizedException(ApiException):
    def __init__(self, message: str = 'Unauthorized', error_code: str = 'unauthorized') -> None:
        super().__init__(status_code=status.HTTP_401_UNAUTHORIZED, message=message, error_code=error_code)
