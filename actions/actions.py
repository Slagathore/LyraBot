import os
import json
import traceback
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from lyra.openai_integration import get_openai_response
from lyra.combined_memory_manager import CombinedMemoryManager
from lyra.ocean import PersonalityEngine
from lyra.memory.sql_memory_manager import log_conversation  # ✅ Ensures SQL logging works

class ActionLogConversation(Action):
    def name(self) -> Text:
        return "action_log_conversation"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:
        try:
            user_message = tracker.latest_message.get("text", "")

            # ✅ Retrieve the bot's last response (instead of static text)
            bot_response = next(
                (event["text"] for event in reversed(tracker.events) if event.get("event") == "bot"), 
                "No response logged"
            )

            log_entry = {
                "user": user_message,
                "bot": bot_response,
                "timestamp": tracker.latest_message.get("timestamp", ""),
            }

            # ✅ Write to conversation_log.txt
            log_file_path = os.path.join(os.getcwd(), "conversation_log.txt")
            with open(log_file_path, "a", encoding="utf-8") as f:
                f.write(f"User: {user_message}\n")
                f.write(f"Bot: {bot_response}\n\n")

            # ✅ Write to conversation_history.json
            json_file_path = os.path.join(os.getcwd(), "conversation_history.json")

            if os.path.exists(json_file_path):
                with open(json_file_path, "r+", encoding="utf-8") as f:
                    try:
                        data = json.load(f)
                        if not isinstance(data, list):
                            data = []
                    except json.JSONDecodeError:
                        data = []

                    data.append(log_entry)
                    f.seek(0)  # Move to the start of the file
                    json.dump(data, f, indent=4)
            else:
                with open(json_file_path, "w", encoding="utf-8") as f:
                    json.dump([log_entry], f, indent=4)

            # ✅ Log to SQL (if available)
            try:
                log_conversation(user_message, bot_response)
            except Exception as e:
                print("❌ SQL memory logging failed:", e)

            print(f"✅ Conversation logged:\n{log_entry}")
            dispatcher.utter_message(text="Conversation logged successfully!")

        except Exception as e:
            print(f"❌ ERROR in ActionLogConversation: {e}")
            traceback.print_exc()
            dispatcher.utter_message(text="Failed to log conversation.")

        return []

class ActionOpenAIChat(Action):
    def name(self) -> Text:
        return "action_openai_chat"

    def __init__(self) -> None:
        super().__init__()
        self.memory_manager = CombinedMemoryManager()
        self.personality_engine = PersonalityEngine()

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:
        user_message = tracker.latest_message.get("text", "")
        if not user_message:
            dispatcher.utter_message(text="I didn't catch that. Could you please repeat?")
            return []

        # Retrieve context for the current query (e.g., top 3 similar past turns)
        memory_data = self.memory_manager.get_context(user_message, k=3)
        context_entries = memory_data["context"]
        context_summary = memory_data["summary"]


        # Format context as a single string to prepend to the prompt
        if not context_entries:
            enriched_prompt = f"{context_summary}\nUser: {user_message}\nBot:"
        else:
            context_str = "\n".join(
                [f"User: {entry.get('user', 'N/A')}\nBot: {entry.get('bot', 'N/A')}" for entry in context_entries]
            )
            enriched_prompt = f"Context:\n{context_str}\n\nUser: {user_message}\nBot:"

        # Add personality context to the prompt
        sentiment = TextBlob(user_message).sentiment
        mood = "positive" if sentiment.polarity > 0 else "neutral" if sentiment.polarity == 0 else "negative"
        personality_context = f"{self.personality_engine.get_personality_context()}\nCurrent Mood: {mood}"
        enriched_prompt = f"{personality_context}\n{enriched_prompt}"

        # Generate a response using the enriched prompt
        try:
            response = get_openai_response(enriched_prompt, model="chatgpt-4o-latest")
        except Exception as e:
            print(f"OpenAI API error: {e}")
            dispatcher.utter_message(text="Sorry, I'm having trouble connecting to OpenAI. Please try again later.")
            return []

        if response and response.strip():
            dispatcher.utter_message(text=response)
        else:
            dispatcher.utter_message(text="Sorry, I couldn't generate a response. Please try again.")

        # ✅ Log the conversation turn with the original user message and bot response
        self.memory_manager.add_memory(
            user_message,
            response or "",
            tags=["important"] if "important" in user_message.lower() else None
        )

        # ✅ Debugging output
        print("Retrieved context:", context_entries)
        print(f"User message: {user_message}")
        print(f"Enriched prompt: {enriched_prompt}")
        print(f"OpenAI response: {response}")

        return []
