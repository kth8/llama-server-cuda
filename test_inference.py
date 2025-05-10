# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "openai",
#     "httpx",
#     "python-magic",
# ]
# ///
import base64
import httpx
from openai import OpenAI
from magic import Magic
mime_detector = Magic(mime=True)

client = OpenAI(base_url="http://127.0.0.1:8080/v1", api_key="llama.cpp")

url = "https://user-images.githubusercontent.com/1991296/230134379-7181e485-c521-4d23-a0d6-f7b3b61ba524.png"
response_content = httpx.get(url, follow_redirects=True).content
response_mime = mime_detector.from_buffer(response_content)
base64_image = base64.b64encode(response_content).decode("utf-8")

completion = client.chat.completions.create(
  model="model-identifier",
    messages=[
      {"role": "system", "content": "You are an AI assistant that analyzes images."},
      {"role": "user", "content": [
          {"type": "text", "text": "Provide a detailed description of this image."},
          {"type": "image_url", "image_url": {"url": f"data:{response_mime};base64,{base64_image}"}
          }
        ]
      }
    ],
    stream=True
)

try:
    for chunk in completion:
        if hasattr(chunk, 'choices') and chunk.choices:
            if hasattr(chunk.choices[0], 'delta'):
                if hasattr(chunk.choices[0].delta, 'content'):
                    content = chunk.choices[0].delta.content
                    if content is not None:
                        print(content, end="", flush=True)
except Exception as e:
    print(f"\nAn error occurred: {str(e)}")
print()

