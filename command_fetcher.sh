#!/bin/bash

# Define the CSV file with tools, commands, and descriptions
TOOL_FILE="tools_commands.csv"

# Define ANSI color codes for better accessibility
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Export a compatible locale for multibyte characters
export LC_ALL=C.UTF-8

# Function to display the unique tools with index numbers, colorizing the index numbers
display_tools() {
    awk -F',' '{gsub(/^"|"$/, "", $1); print $1}' "$TOOL_FILE" | sort | uniq | nl | while read -r number name; do
        printf "${YELLOW}%d${NC}: %s\n" "$number" "$name"
    done
}

# Function to get the selected tool's name based on the index
get_tool_by_index() {
    local tool_index=$1
    awk -F',' '{gsub(/^"|"$/, "", $1); print $1}' "$TOOL_FILE" | sort | uniq | sed -n "${tool_index}p"
}

# Function to list all commands for a selected tool using Python
list_commands_for_tool() {
    local tool=$1
    python3 csv_parser_list.py "$TOOL_FILE" "$tool"
}

# Function to get the command and description for a selected index using Python
get_command_and_description_for_index() {
    local cmd_index=$1
    python3 csv_parser.py "$TOOL_FILE" "$cmd_index"
}

# Function to search the third column for a keyword and handle special characters safely with color coding
search_by_keyword() {
    local keyword=$1
    echo -e "${CYAN}Searching for '$keyword' in descriptions...${NC}"

    awk -F',' -v keyword="$keyword" '
    BEGIN { IGNORECASE = 1 }
    $3 ~ keyword {
        gsub(/^"|"$/, "", $2); 
        gsub(/^"|"$/, "", $3); 
        printf "'"${YELLOW}"'%d'"${NC}"': '"${GREEN}"'%s'"${NC}"'\n'"${MAGENTA}"'Description: '"${NC}"'%s\n\n", NR, $2, $3
    }' "$TOOL_FILE"
}

# Main interactive loop
while true; do
    # Prompt user to choose mode: Index Mode or Search Mode
    echo -e "${WHITE}Choose a mode:${NC}"
    echo -e "${WHITE}1. Index Mode${NC}"
    echo -e "${WHITE}2. Search Mode${NC}"
    echo -e "${WHITE}Type 'exit' to quit.${NC}"
    read -p "" mode

    # Allow the user to exit the script
    if [[ "$mode" == "exit" ]]; then
        echo "Exiting..."
        break
    fi

    # Index Mode
    if [[ "$mode" == "1" ]]; then
        while true; do
            # Display the unique tools with index numbers
            echo -e "${CYAN}Select a tool by entering the corresponding index number or type 'back' to return to the main menu:${NC}"
            display_tools

            # Prompt user for input
            echo -e "${CYAN}Enter the tool index number:${NC}"
            read -p "" tool_index

            # Allow the user to go back to the main menu
            if [[ "$tool_index" == "back" ]]; then
                break
            fi

            # Fetch the tool name based on the index
            selected_tool=$(get_tool_by_index "$tool_index")

            if [ -z "$selected_tool" ]; then
                echo -e "${CYAN}Invalid index number.${NC}"
                continue
            fi

            # List all commands for the selected tool using the Python script
            echo -e "${CYAN}Commands for tool '$selected_tool':${NC}"
            list_commands_for_tool "$selected_tool"

            # Sub-loop for command selection without redisplaying the list of commands
            while true; do
                # Prompt user for input to select a specific command or go back
                echo -e "${CYAN}Enter the command index number or type 'back' to choose another tool:${NC}"
                read -p "" cmd_index

                # Allow the user to go back to the previous menu
                if [[ "$cmd_index" == "back" ]]; then
                    break
                fi

                # Ensure the command index is numeric
                if ! [[ "$cmd_index" =~ ^[0-9]+$ ]]; then
                    echo -e "${CYAN}Invalid command index. Please enter a number or type 'back'.${NC}"
                    continue
                fi

                # Fetch the selected command and its description using the Python script
                selected_output=$(get_command_and_description_for_index "$cmd_index")
                selected_command=$(echo "$selected_output" | cut -d'|' -f1)
                selected_description=$(echo "$selected_output" | cut -d'|' -f2)

                # Check if the command and description are valid
                if [ -z "$selected_command" ] || [ -z "$selected_description" ]; then
                    echo -e "${CYAN}No valid command or description found for the selected index.${NC}"
                else
                    # Display the selected command in green and the description in magenta
                    echo -e "${GREEN}Command Selected:${NC} $selected_command"
                    echo -e "${MAGENTA}Description:${NC} $selected_description"
                fi
            done
        done

    # Search Mode
    elif [[ "$mode" == "2" ]]; then
        # Stay in search mode until 'back' is typed
        while true; do
            # Prompt user to enter a keyword for searching
            echo -e "${CYAN}Enter a keyword to search the descriptions or type 'back' to return to the main menu:${NC}"
            read -p "" keyword

            # Allow the user to go back to the main menu
            if [[ "$keyword" == "back" ]]; then
                break
            fi

            # Search the descriptions and display matching commands
            search_by_keyword "$keyword"
        done

    else
        echo -e "${CYAN}Invalid mode selection. Please choose 1 for Index Mode or 2 for Search Mode.${NC}"
    fi
done

