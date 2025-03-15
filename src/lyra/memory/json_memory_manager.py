import json
import os
from typing import List, Dict, Any, Optional

class JSONMemoryManager:
    def __init__(self, file_path="conversation_history.json"):
        """
        Initializes the JSON memory manager, aiming for human-like curiosity and detailed memory tracking.

        Parameters:
            file_path (str): Path to the JSON file used for persisting conversation history.
        """
        base_dir = os.path.join(os.getcwd(), "src", "lyra", "memory")
        self.file_path = os.path.join(base_dir, file_path)
        self.load_memory()

    def load_memory(self) -> None:
        """
        Loads conversation history from the JSON file.
        """
        if os.path.exists(self.file_path):
            try:
                with open(self.file_path, "r", encoding="utf-8") as f:
                    self.memory = json.load(f)
                    if not isinstance(self.memory, list):
                        self.memory = []
            except Exception as e:
                print(f"Error loading memory: {e}")
                self.memory = []
        else:
            self.memory = []

    def save_memory(self):
        """
        Saves the current conversation history to the file.
        """
        try:
            with open(self.file_path, "w", encoding="utf-8") as f:
                json.dump(self.memory, f, indent=4, ensure_ascii=False)
        except Exception as e:
            print(f"Error saving memory: {e}")

    def add_memory(self, entry: Dict[str, Any]) -> None:
        """
        Adds a new conversation entry to memory and persists it. Ensures tags and sentiment are always present.

        Parameters:
            entry (dict): A dictionary representing a conversation turn
                          (e.g., {"user": "...", "bot": "...", "tags": ["important"],
                                  "sentiment": {"polarity": 0.0, "subjectivity": 0.0}}).
        """
        if "tags" not in entry:
            entry["tags"] = []
        if "sentiment" not in entry:
            entry["sentiment"] = {"polarity": 0.0, "subjectivity": 0.0}

        self.memory.append(entry)
        self.save_memory()

    def get_memory(self) -> List[Dict[str, Any]]:
        """
        Retrieves the entire conversation history.
        """
        return self.memory

    def get_tagged_memory(self, tag: str) -> List[Dict[str, Any]]:
        """
        Retrieves memory entries filtered by a specific tag.

        Parameters:
            tag (str): The tag to filter entries by.
        """
        return [entry for entry in self.memory if tag in entry.get("tags", [])]

    def get_recent_memory(self, num_entries: int = 5) -> List[Dict[str, Any]]:
        """
        Retrieves a specified number of the most recent conversation entries.

        Parameters:
            num_entries (int): Number of recent entries to retrieve.
        """
        return self.memory[-num_entries:]
