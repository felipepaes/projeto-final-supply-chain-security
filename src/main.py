import uvicorn
from litestar import Litestar, Router

def create_app() -> Litestar:
    from controllers.hello import HelloController
    from controllers.index import IndexController

    index_router = Router(
        path="/",
        route_handlers=[IndexController]
    )

    api_router = Router(
        path="/api",
        route_handlers=[HelloController]
    )

    return Litestar(route_handlers=[index_router, api_router])

app = create_app()

if __name__ == "__main__":
    uvicorn.run(app)
