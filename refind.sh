#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Function to print help information
print_help() {
  echo -e "${CYAN}Usage: refind [SEARCH_TERM] [DIRECTORY]${NC}"
  echo
  echo -e "${GREEN}Options:${NC}"
  echo -e "  ${YELLOW}SEARCH_TERM${NC}    The term to search for using the find command."
  echo -e "  ${YELLOW}[DIRECTORY]${NC}      The directory to search in (optional, default is current directory)."
  echo
  echo -e "${GREEN}Example:${NC}"
  echo -e "  ${WHITE}./refind \"vc_red.msi\" /path/to/search${NC}"
  echo -e "  ${WHITE}./refind \"vc_red.msi\"${NC}  (searches in the current directory)"
  echo
  echo -e "${GREEN}Description:${NC}"
  echo -e "  This script searches for files matching the SEARCH_TERM in the specified"
  echo -e "  DIRECTORY (or current directory if not specified). It displays the search"
  echo -e "  progress and results in a color-coded format."
  echo -e "  On script exit, it shows detailed results and cleans up temporary log files."
}

# Check for --help argument
if [[ "$1" == "--help" ]]; then
  print_help
  exit 0
fi

# Generate a base64 string and make it URL-safe
generate_id() {
  openssl rand -base64 12 | tr -dc 'A-Za-z0-9-_'
}

# Function for mycat
mycat() {
  id="-${1}"

  echo -e "${BLUE}STDIN:${NC} $(cat ~/input${id}.log)"
  echo
  echo -e "${GREEN}STDOUT:${NC} $(wc -l < ~/output${id}.log) lines"
  cat ~/output${id}.log
  echo
  echo -e "${RED}STDERR:${NC} $(wc -l < ~/error${id}.log) lines"
  echo -e "${RED}(omitted)"
}

# Function for myfind
myfind() {
  # Generate a base64 string and make it URL-safe
  generate_id() {
    openssl rand -base64 12 | tr -dc 'A-Za-z0-9-_'
  }

  # Check arguments and set variables accordingly
  if [ $# -eq 3 ]; then
    search_dir="$2"
    id="$3"
  elif [ $# -eq 2 ]; then
    search_dir="$2"
    id=$(generate_id)
  else
    search_dir="."
    id=$(generate_id)
  fi

  # Create log files with the unique ID
  touch ~/input-$id.log
  touch ~/output-$id.log
  touch ~/error-$id.log

  # Write the find command to input.log
  echo "find \"$search_dir\" 2> ~/error-$id.log | grep -i \"$1\" > ~/output-$id.log" > ~/input-$id.log

  # Execute the find command from input.log and redirect output and errors
  bash ~/input-$id.log
}

# Function for myfullcat
myfullcat() {
  id="-${1}"

  echo
  echo
  echo -e "${BLUE}STDIN:${NC}"
  cat ~/input${id}.log
  echo
  echo -e "${GREEN}STDOUT:${NC} $(wc -l < ~/output${id}.log) lines"
  cat ~/output${id}.log
  echo
  echo
  echo -e "${RED}STDERR:${NC} $(wc -l < ~/error${id}.log) lines"
  cat ~/error${id}.log
  echo
}

# Function for cleanup
cleanup() {
  tput cnorm
  myfullcat "$unique_id"
  rmlogs
  exit
}

# Function for rmlogs
rmlogs() {
  rm -rf ~/input-*.log
  rm -rf ~/output-*.log
  rm -rf ~/error-*.log
}

# Generate a unique ID
unique_id=$(generate_id)

# Hide the cursor
tput civis

# Ensure the cursor is shown again on script exit
trap 'tput cnorm; exit' INT TERM
trap 'cleanup' EXIT

# Get the number of rows in the terminal
rows=$(tput lines)

# Calculate the number of rows available for output
output_rows=$((rows - 5))

# Check if the directory parameter is provided as the second argument; if not, default to current directory
search_dir="${2:-.}"

# Run the find script in the background with the search term, directory, and unique ID
myfind "$1" "$search_dir" "$unique_id" &

while true; do
  clear

  # Clear the top part of the screen and run mycat with the unique ID
  tput cup 0 0
  tput el
  total_lines=$(wc -l < ~/output-$unique_id.log)

  # Display the output and limit it to the available rows
  mycat "$unique_id" | head -n $output_rows

  # Display "Plus x more files..." if there are more lines than available rows
  if [ "$total_lines" -gt "$output_rows" ]; then
    tput cup $((output_rows)) 0
    tput el
    echo -e "${YELLOW}Plus $((total_lines - output_rows)) more files...${NC}"
  fi

  # Move the cursor to the second last row and show progress
  tput cup $((rows-3)) 0
  tput el
  echo -e "${CYAN}Found $total_lines files${NC}"

  # Move the cursor to the last row and show error count
  tput cup $((rows-2)) 0
  tput el
  echo -e "${MAGENTA}Errors: $(wc -l < ~/error-$unique_id.log)${NC}"

  tput cup $((rows-1)) 0
  tput el
  echo -n "imgnx-refind"
  sleep 1
done
