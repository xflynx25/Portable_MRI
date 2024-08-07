# run_script.py
import os
import sys
import subprocess

def run_script(script_name):
    """
    Run a script by its name.
    """
    try:
        subprocess.run(['python', script_name], check=True)
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while running the script: {e}")
    except FileNotFoundError:
        print(f"Script not found: {script_name}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python run_script.py <script_name>")
        sys.exit(1)

    script_to_run = sys.argv[1]
    run_script(script_to_run)
