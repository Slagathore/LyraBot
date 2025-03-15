import os
import json
import numpy as np
from datetime import datetime
from textblob import TextBlob
from typing import List, Optional, Dict, Any
from lyra.memory.json_memory_manager import JSONMemoryManager
from lyra.memory.faiss_memory_manager import FAISSMemoryManager
from lyra.memory.sql_memory_manager import log_conversation
from lyra.langchain_integration import create_conversation_chain
from sentence_transformers import SentenceTransformer

class CombinedMemoryManager:
    def __init__(self):
        json_file = os.path.join(os.getcwd(), "conversation_history.json")
        self.json_manager = JSONMemoryManager(file_path=json_file)
        self.faiss_manager = FAISSMemoryManager(dim=384, index_file="faiss_index.bin")
        self.conversation_chain = create_conversation_chain()
        self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')

    def add_memory(self, user_message: str, bot_response: str, tags: Optional[List[str]] = None, conversation_id: Optional[str] = None):
        print(f"🛠 Logging memory: {user_message} -> {bot_response}")

        timestamp = datetime.now().isoformat()
        sentiment = TextBlob(user_message).sentiment

        tags = tags if tags else []
        if "important" in user_message.lower() or "important" in bot_response.lower():
            if "important" not in tags:
                tags.append("important")

        entry = {
            "user": user_message,
            "bot": bot_response,
            "timestamp": timestamp,
            "tags": tags,
            "sentiment": {
                "polarity": sentiment.polarity,
                "subjectivity": sentiment.subjectivity,
            },
        }

        try:
            self.json_manager.add_memory(entry)
        except Exception as e:
            print("❌ Error in JSON logging:", e)

        try:
            log_conversation(user_message, bot_response)
        except Exception as e:
            print("❌ SQL logging failed:", e)

        try:
            embedding = self.text_to_embedding(user_message + " " + bot_response)
            self.faiss_manager.add_embedding(embedding, entry)
        except Exception as e:
            print("❌ FAISS embedding failed:", e)

        log_file_path = os.path.join(os.getcwd(), "conversation_log.txt")
        try:
            with open(log_file_path, "a", encoding="utf-8") as f:
                f.write(f"{timestamp}\nUser: {user_message}\nBot: {bot_response}\n\n")
        except Exception as e:
            print("❌ File logging failed:", e)

        print(f"✅ Conversation logged successfully: {entry}")

    def text_to_embedding(self, text: str) -> np.ndarray:
        return self.embedding_model.encode(text)

    def get_context(self, query_text: str, k: int = 5) -> Dict[str, Any]:
        query_embedding = self.text_to_embedding(query_text)
        distances, results = self.faiss_manager.search(query_embedding, k=k)

        current_time = datetime.now()
        for result in results:
            timestamp = datetime.fromisoformat(result["timestamp"])
            age = (current_time - timestamp).total_seconds() / 3600
            decay_factor = max(0, 1 - (age / 24))

            if "important" in result.get("tags", []):
                decay_factor = 1.0

            if "score" in result:
                result["score"] *= decay_factor

        results.sort(key=lambda x: x.get("score", 0), reverse=True)
        unique_results = self.faiss_manager.deduplicate_entries(results)

        summary = self.conversation_chain.run(f"Summarize these past conversations: {unique_results}")
        return {"context": unique_results, "summary": summary}


if __name__ == "__main__":
    cmm = CombinedMemoryManager()
    cmm.add_memory("Test", "Test response", ["important"])