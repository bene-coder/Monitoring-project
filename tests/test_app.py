import os
import sys
import pytest

app_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '../app'))
sys.path.insert(0, app_dir)

from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}