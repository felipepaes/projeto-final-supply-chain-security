import msgspec

class HelloDTO(msgspec.Struct):
    message: str
