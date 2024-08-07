import sys
import os

def add_paths_to_sys(paths):
    """
    Add a list of directories to the sys.path for the current session.
    """
    for path in paths:
        # Resolve the absolute path
        full_path = os.path.abspath(path)
        
        # Check if the path is valid and is a directory
        if os.path.isdir(full_path) and full_path not in sys.path:
            sys.path.append(full_path)
            print(f'Added to sys.path: {full_path}')
        else:
            print(f'Invalid or already in sys.path: {full_path}')

# List of directories you want to add
directories_to_add = [
    '/Users/jflyn/Documents/martinos_docs_windows/Projects/editor_tf_fits/Scripts/python/',
]

# Add directories to sys.path
add_paths_to_sys(directories_to_add)
