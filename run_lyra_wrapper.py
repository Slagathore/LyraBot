"""
Wrapper script to run Lyra with the correct environment
"""
import os
import sys
import subprocess
import platform
from pathlib import Path

def find_virtual_env():
    """Find a suitable virtual environment"""
    # Check for common environment folder names
    env_names = ["lyra_env", "venv", "env", ".venv"]
    
    for name in env_names:
        if os.path.exists(name):
            return Path(name)
    
    return None

def run_lyra():
    """Run Lyra with the correct environment"""
    env_path = find_virtual_env()
    
    if not env_path:
        print("❌ No virtual environment found. Please run 'python resolve_dependencies.py' first.")
        return False
    
    # Determine the python path in the virtual environment
    if platform.system() == "Windows":
        python_path = env_path / "Scripts" / "python"
    else:
        python_path = env_path / "bin" / "python"
    
    if not os.path.exists(python_path):
        print(f"❌ Python not found in virtual environment at {python_path}")
        return False
    
    try:
        # Run Lyra main module
        subprocess.run([str(python_path), "-m", "lyra.main"], check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error running Lyra: {e}")
        return False
    except KeyboardInterrupt:
        print("\nLyra shutting down...")
        return True

if __name__ == "__main__":
    run_lyra()
