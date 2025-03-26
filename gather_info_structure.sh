#!/bin/bash

# Define the output file
output_file="info_structure.txt"

# Function to recursively list directory contents
list_directory() {
    local dir="$1"
    local prefix="$2"
    
    for item in "$dir"/*; do
        if [ -e "$item" ]; then
            echo "${prefix}$(basename "$item")"
            if [ -d "$item" ]; then
                list_directory "$item" "  ${prefix}"
            fi
        fi
    done
}

# Clear the file if it exists, or create a new one
> "$output_file"

# Write the directory structure to the file
list_directory "." "" > "$output_file"

echo "Folder structure has been saved to $output_file"