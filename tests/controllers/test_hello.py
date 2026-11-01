from litestar import status_codes

def test_hello_controller(test_client):
    """Test the HelloController route."""
    response = test_client.get("/api/hello/")
    assert response.status_code == status_codes.HTTP_200_OK
    assert response.json() == {"message": "Hello from the HelloController!"}
