import csv
import sys

def get_command_and_description(csv_file, line_number):
    # Open the CSV file with a more tolerant encoding approach
    with open(csv_file, 'r', encoding='utf-8', errors='replace') as file:
        reader = csv.reader(file)
        for i, row in enumerate(reader, start=1):
            if i == line_number:
                command = row[1].strip()
                description = row[2].strip()
                return command, description
    return None, None

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: csv_parser.py <csv_file> <line_number>")
        sys.exit(1)

    csv_file = sys.argv[1]
    line_number = int(sys.argv[2])
    command, description = get_command_and_description(csv_file, line_number)
    if command and description:
        print(f"{command}|{description}")
    else:
        print("No valid command or description found")

