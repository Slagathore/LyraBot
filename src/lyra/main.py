from memory_manager import init_db, log_conversation
from openai_integration import get_openai_response

def main():
    # Initialize the database if not already initialized
    init_db()
    
    print("Lyra is online. Start your conversation:")
    while True:
        user_input = input("You: ")
        if user_input.lower() in ["exit", "quit"]:
            print("Goodbye!")
            break
        
        # Generate a response using GPT-4o latest model
        bot_response = get_openai_response(user_input, model="chatgpt-4o-latest")
        print("Lyra:", bot_response)
        
        # Log the conversation for long-term memory
        log_conversation(user_input, bot_response)

if __name__ == "__main__":
    main()
