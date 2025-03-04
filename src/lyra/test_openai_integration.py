import pytest
from .openai_integration import get_openai_response, client, OpenAIError

# A fake response object to simulate a successful API call
class FakeResponse:
    def __init__(self, content):
        self.choices = [type("FakeChoice", (), {"message": type("FakeMessage", (), {"content": content})})()]

def fake_success_response(*args, **kwargs):
    # Return a fake response with predetermined content
    return FakeResponse("Fake Response")

def fake_error_response(*args, **kwargs):
    # Simulate an API error
    raise OpenAIError("Fake Error: model not found")

def test_valid_response(monkeypatch):
    # Monkeypatch the client's chat completions create method to return a fake success response
    monkeypatch.setattr(client.chat.completions, "create", fake_success_response)
    response = get_openai_response("Test prompt", model="valid-model")
    assert response == "Fake Response"

def test_error_handling(monkeypatch, capsys):
    # Monkeypatch to simulate an error in the API call
    monkeypatch.setattr(client.chat.completions, "create", fake_error_response)
    response = get_openai_response("Test prompt", model="invalid-model")
    captured = capsys.readouterr().out
    assert "Caught an OpenAI error:" in captured
    assert response is None
