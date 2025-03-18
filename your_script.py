import os

# Ensure the OPENAI_API_KEY environment variable is set
api_key = os.getenv('OPENAI_API_KEY')
if not api_key:
    raise ValueError("The OPENAI_API_KEY environment variable is not set")

# Ensure the openai package is installed
try:
    import openai
except ImportError:
    import subprocess
    subprocess.check_call(["poetry", "add", "openai"])
    import openai

# Initialize the OpenAI client
openai.api_key = api_key

# ...existing code...