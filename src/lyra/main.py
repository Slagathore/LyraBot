from lyra.memory_manager import init_db, log_conversation
from lyra.openai_integration import get_openai_response
from lyra.combined_memory_manager import CombinedMemoryManager
from lyra.ocean import PersonalityEngine

def main():
    # Initialize the database if not already initialized
    init_db()
    
    # Initialize memory and personality
    memory_manager = CombinedMemoryManager()
    personality_engine = PersonalityEngine()

    print("Lyra is online. Start your conversation:")
    while True:
        user_input = input("You: ")
        if user_input.lower() in ["exit", "quit"]:
            print("Goodbye!")
            break
        
        # Generate a response using GPT-4o latest model
        personality_context = personality_engine.get_personality_context()
        bot_response = get_openai_response(f"{personality_context}\nUser: {user_input}\nBot:", model="chatgpt-4o-latest")
        print("Lyra:", bot_response)
        
        # Log the conversation for long-term memory
        memory_manager.add_memory(user_input, bot_response, personality_context)

if __name__ == "__main__":
    main()