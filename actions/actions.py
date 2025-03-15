import os
import json
import traceback
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from lyra.openai_integration import get_openai_response
from lyra.combined_memory_manager import CombinedMemoryManager
from lyra.ocean import PersonalityEngine
from lyra.memory.sql_memory_manager import log_conversation
from datetime import datetime
from textblob import TextBlob

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
            bot_response = next(
                (event["text"] for event in reversed(tracker.events) if event.get("event") == "bot"), 
                "No response logged"
            )
            timestamp = datetime.now().isoformat()

            tags = []
            if "important" in user_message.lower() or "important" in bot_response.lower():
                tags.append("important")

            sentiment = TextBlob(user_message).sentiment
            log_entry = {
                "user": user_message,
                "bot": bot_response,
                "timestamp": timestamp,
                "tags": tags,
                "sentiment": {
                    "polarity": sentiment.polarity,
                    "subjectivity": sentiment.subjectivity,
                }
            }

            json_file_path = os.path.join(os.getcwd(), "conversation_history.json")
            if os.path.exists(json_file_path):
                with open(json_file_path, "r+", encoding="utf-8") as f:
                    data = json.load(f)
                    data.append(log_entry)
                    f.seek(0)
                    json.dump(data, f, indent=4)
            else:
                with open(json_file_path, "w", encoding="utf-8") as f:
                    json.dump([log_entry], f, indent=4)

            log_file_path = os.path.join(os.getcwd(), "conversation_log.txt")
            with open(log_file_path, "a", encoding="utf-8") as f:
                f.write(f"{timestamp}\nUser: {user_message}\nBot: {bot_response}\n\n")

            log_conversation(user_message, bot_response)

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

        memory_data = self.memory_manager.get_context(user_message, k=3)
        context_entries = memory_data["context"]
        context_summary = memory_data["summary"]

        context_str = "\n".join(
            [f"User: {entry.get('user', '')}\nBot: {entry.get('bot', '')}" for entry in context_entries]
        )
        sentiment = TextBlob(user_message).sentiment
        mood = "positive" if sentiment.polarity > 0 else "neutral" if sentiment.polarity == 0 else "negative"

        personality_context = f"{self.personality_engine.get_personality_context()}\nCurrent Mood: {mood}"
        enriched_prompt = f"{personality_context}\n{context_summary}\nContext:\n{context_str}\n\nUser: {user_message}\nBot:"

        response = get_openai_response(enriched_prompt, model="chatgpt-4o-latest")

        dispatcher.utter_message(text=response)

        tags = []
        if "important" in user_message.lower() or "important" in response.lower():
            tags.append("important")

        self.memory_manager.add_memory(user_message, response, tags)

        try:
            log_conversation(user_message, response)
        except Exception as e:
            print("SQL logging error:", e)

        return []
