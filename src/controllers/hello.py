from litestar import Controller, get, MediaType
from  dto.hello import HelloDTO

class HelloController(Controller):
    path = "/hello"

    @get("/", media_type=MediaType.JSON, sync_to_thread=True)
    def hello(self) -> HelloDTO:
        return HelloDTO(message="Hello from the HelloController!")
  