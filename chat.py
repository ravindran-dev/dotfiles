#!/usr/bin/env python3

from openai import OpenAI
from dotenv import load_dotenv
import os, time


load_dotenv()

API_KEY = os.getenv("API_KEY")




client = OpenAI(
    api_key=API_KEY,
    base_url="https://openrouter.ai/api/v1"
)

print("💬 OpenRouter Chat Terminal (type 'exit' to quit)\n")

messages = []

while True:
    try:
        user_input = input("You: ").strip()
        if user_input.lower() in ["exit", "quit"]:
            print("👋 Goodbye!")
            break

        messages.append({"role": "user", "content": user_input})

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages
        )

        reply = response.choices[0].message.content
        messages.append({"role": "assistant", "content": reply})

        print(f"\n\nGPT: {reply}\n\n")

    except KeyboardInterrupt:
        print("\n👋 Session ended.")
        break
    except Exception as e:
        print(f"⚠️ Error: {e}\n")
