from litestar import status_codes

def test_index_controller(test_client):
    """Test the index route."""
    response = test_client.get("/")
    assert response.status_code == status_codes.HTTP_200_OK
    assert "Experimente acessar" in response.text

