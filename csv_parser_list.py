import csv
import sys

def list_commands_for_tool(csv_file, tool_name):
    with open(csv_file, 'r', encoding='utf-8', errors='replace') as file:
        reader = csv.reader(file)
        for i, row in enumerate(reader, start=1):
            if row[0].strip() == tool_name:
                print(f"{i}: {row[1].strip()}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: csv_parser_list.py <csv_file> <tool_name>")
        sys.exit(1)

    csv_file = sys.argv[1]
    tool_name = sys.argv[2]
    list_commands_for_tool(csv_file, tool_name)

