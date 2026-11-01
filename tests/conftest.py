import pytest
from litestar.testing import TestClient
from litestar import Litestar
from collections.abc import Iterator
from main import create_app

app = create_app()
app.debug = True

@pytest.fixture(scope="function")
def test_client() -> Iterator[TestClient[Litestar]]:
    with TestClient(app=app) as client:
        yield client