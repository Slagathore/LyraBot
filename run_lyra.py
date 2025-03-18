"""
Script to run Lyra directly
"""
import os
import subprocess
import sys

def run_lyra():
    """Run Lyra using Poetry"""
    try:
        # Run Lyra using Poetry
        subprocess.run(["poetry", "run", "python", "-m", "lyra.main"], check=True)
    except KeyboardInterrupt:
        print("\nLyra shutdown by user.")
    except Exception as e:
        print(f"❌ Error: {e}")
        
if __name__ == "__main__":
    run_lyra()
