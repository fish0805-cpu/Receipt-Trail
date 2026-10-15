class RepositoryError(Exception):
    """Base class for persistence errors safe to expose across adapters."""


class DuplicateEmailError(RepositoryError):
    pass


class RepositoryConflictError(RepositoryError):
    pass


class RecordNotFoundError(RepositoryError):
    pass
