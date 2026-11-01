from litestar import Controller, get, MediaType

class IndexController(Controller):

    @get("/", media_type=MediaType.TEXT, sync_to_thread=True)
    def main(self) -> str:
        return "Experimente acessar a rota /api/hello para ver a resposta do endpoint de hello."