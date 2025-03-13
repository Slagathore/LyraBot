import os
from openai import OpenAI, OpenAIError

# Retrieve the API key from the environment variable "OPENAI_API_KEY"
# Fallback to your provided key if the environment variable is not set
API_KEY = os.getenv("OPENAI_API_KEY")

client = OpenAI(api_key=API_KEY)

def get_openai_response(prompt: str, model="chatgpt-4o-latest", max_tokens=150, temperature=0.7):
    """
    Call the OpenAI API using the new synchronous client interface and return the generated response.
    """
    try:
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=max_tokens,
            temperature=temperature
        )
        return response.choices[0].message.content.strip()
    except OpenAIError as e:
        print("Caught an OpenAI error:", e)
        return None

if __name__ == "__main__":
    # Test with a valid prompt using the correct model
    test_prompt = "Hello, how are you today?"
    result = get_openai_response(test_prompt)
    print("OpenAI API response:", result)

    # Test error handling by intentionally using an invalid model name
    print("\nTesting error handling with an invalid model:")
    invalid_model = "invalid-model"
    result_error = get_openai_response(test_prompt, model=invalid_model)
    if result_error is None:
        print("Error was successfully caught and handled.")
    else:
        print("Unexpected response:", result_error)
