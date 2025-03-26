#!/bin/bash

# Script to gather system information (OS, Disk, GPU) and write to a file.
#
# Usage:
#   ./gather_info_system.sh [options]
#
# Options:
#   --os    Include OS and CPU information.
#   --disk  Include disk and partition information.
#   --gpu   Include GPU and CUDA related information.
#
# If no options are provided, all sections (OS, Disk, GPU) will be included.
# Output is written to info_system.txt in the same directory.

# Output file
OUTPUT_FILE="info_system.txt"

# Function to run command and append output to file
run_command() {
    echo "$ $1" >> "$OUTPUT_FILE"
    eval "$1" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Function to run command with sudo and append output to file
run_sudo_command() {
  echo "$ sudo $1" >> "$OUTPUT_FILE"
  if ! sudo $1 >> "$OUTPUT_FILE" 2>&1; then
    echo "Error: Could not execute sudo command: $1" >> "$OUTPUT_FILE"
  fi
  echo "" >> "$OUTPUT_FILE"
}

# Initialize flags
run_system=false
run_disk=false
run_gpu=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --os)
      run_system=true
      shift
      ;;
    --disk)
      run_disk=true
      shift
      ;;
    --gpu)
      run_gpu=true
      shift
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done

# Run all sections if no arguments are provided
if ! $run_system && ! $run_disk && ! $run_gpu; then
  run_system=true
  run_disk=true
  run_gpu=true
fi

# Build the list of included sections
included_sections_list=()
if $run_system; then included_sections_list+=("OS"); fi
if $run_disk; then included_sections_list+=("Disk"); fi
if $run_gpu; then included_sections_list+=("GPU"); fi

# Join the list into a comma-separated string (or handle "None")
if [ ${#included_sections_list[@]} -eq 0 ]; then
  included_sections="None specified"
else
  # Simple comma join
  included_sections=$(printf ", %s" "${included_sections_list[@]}")
  included_sections=${included_sections:2} # Remove leading ", "
fi

# Create the file if it doesn't exist, or clear it if it does
touch "$OUTPUT_FILE"
> "$OUTPUT_FILE"

# Add a brief description at the top of the file
cat << EOF > "$OUTPUT_FILE"
# System Information Report
# This file contains system details for: $included_sections.

EOF

# Gather system information
os_info() {
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo " ============================================ OS Info ============================================ " >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    run_command "uname -a"
    run_command "uname -o"
    run_command "uname -m"
    run_command "lscpu"
}

# Gather DISK information
disk_info() {
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo " ============================================ Disk Info ============================================ " >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    run_command "lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE"
    run_sudo_command "parted -l"
}

# GPU related
gpu_info() {
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo " ============================================ GPU Info ============================================ " >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    run_command "nvidia-smi"
    run_command "pip list | grep cuda"
    run_command "ldconfig -p | grep cuda"
    run_command "nvcc --version"
    run_command "which nvcc"
}

# Execute sections based on flags
if $run_system; then
  os_info
fi

if $run_disk; then
  disk_info
fi

if $run_gpu; then
  gpu_info
fi

echo "System information has been written to $OUTPUT_FILE"
