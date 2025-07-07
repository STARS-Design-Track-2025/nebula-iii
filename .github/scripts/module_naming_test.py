# -*- coding: utf-8 -*-
"""
Created on Sat Dec  7 15:43:51 2024

@author: Aidan Jacobsen, Chat GPT
"""

import os
import glob
import re
import sys

print("If you would like to test this step locally, run .github/scripts/module_naming_test.py")

error_count = 0

def validate_modules(module_list):
    global error_count
    # Condition 3: Regex to match "team_##" and "t##_module_name"
    team_pattern = re.compile(r't([0-9][0-9])_')

    # To track modules and their occurrences
    module_names = {}

    for file, line_number, module in module_list:
        if re.match(r"team_[0-9][0-9]_WB", module):
            continue # Ignore the default modules
        if re.match(r"team_[0-9][0-9]", module):
            continue # Ignore the default modules
        if re.match(r"team_[0-9][0-9]_Wrapper", module):
            continue # Ignore the default modules
        if re.match(r"top", module) and re.match(r"team_[0-9][0-9]_fpga_top", os.path.basename(file)):
            continue # Ignore the default modules
        # Condition 1: Module name should match the root of the filename (without extension)
        filename_without_extension = file.split('/')[-1].split('.')[0].split("/")[-1].split("\\")[-1]
        if filename_without_extension != module:
            print(f"Error in {os.path.basename(file)}: Module '{module}' does not match the root of the file '{os.path.basename(file)}'")
            error_count += 1
        # Condition 2: Check if the module name has already been declared
        if module in module_names:
            print(f"Error in {os.path.basename(file)}: Module '{module}' is declared more than once.")
            error_count += 1
        else:
            module_names[module] = (file, line_number)

        # Condition 3: Check if the module matches the "t##_module_name" format
        match = team_pattern.match(module)
        if match:
            team_number = match.group(1)
            if not module.startswith(f"t{int(team_number):02d}_"):
                error_count += 1
                print(f"Error in {os.path.basename(file)}: Module '{module}' does not follow the required 't##_module_name' format.")
        else:
            error_count += 1
            print(f"Error in {os.path.basename(file)}: Module '{module}' does not match 't##_module_name' format.")

def find_root_directory(start_path):
    # Check if running in GitHub Actions
    github_workspace = os.getenv("GITHUB_WORKSPACE")
    if github_workspace:
        return github_workspace

    # Fallback to local method
    current_path = os.path.abspath(os.path.dirname(__file__))
    while current_path != os.path.dirname(current_path):
        if os.path.isdir(os.path.join(current_path, '.git')):
            return current_path
        current_path = os.path.dirname(current_path)
    print("Project directory not found")
    return None  # Return None if project directory is not found

verilog_directory = find_root_directory(os.getcwd()) + "/verilog"

team_project_directory = verilog_directory + "/rtl/team_projects"

# Get all folders in the directory
team_folders = [f for f in glob.glob(os.path.join(team_project_directory, '*')) if os.path.isdir(f)]

teams = [os.path.basename(folder) for folder in team_folders]

print("Found verilog for Teams: ", teams)

for team, team_folder in zip(teams, team_folders):
    print(f"Checking files for: {team}")
    
    team_files = glob.glob(f'{team_folder}/**/*.v', recursive=True) + glob.glob(f'{team_folder}/**/*.sv', recursive=True)
    
    # Find the names of each module.
    module_pattern = re.compile(r'\bmodule\s+(\w+)\s*#?\(')
    module_info = []
    # Iterate through the files and search for module names
    for file in team_files:
        with open(file, 'r') as f:
            lines = f.readlines()
            # Check each line for module pattern
            for line_number, line in enumerate(lines, start=1):
                matches = module_pattern.findall(line)  # Find all matches in the current line
                for match in matches:
                    module_info.append((file, line_number, match))

    # Print the list of modules with filenames and line numbers
    print("Found the following modules")
    for file, line_number, module in module_info:
        print(f"File: {os.path.basename(file)}, Line: {line_number}, Module: {module}")
    
    validate_modules(module_info)
    
    
print(f"Total Number of Naming Issues: {error_count}")
if(error_count > 0):
    print("Exiting with nonzero number of naming issues")
    sys.exit(1)