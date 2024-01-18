import csv
import sys

if len(sys.argv) != 2:
    print("Enter one argument for program to read csv. ")
    print("python3 /home/mhartney/PycharmProjects/pythonProject/csvReader.py <path_to_csv>")
    sys.exit(1)

# Get csv file from user input on command line.
input_csv = sys.argv[1]

row_count = 0
asset_count = 0
seq_count = 0
other_count = 0

# Open the CSV file in read mode.
with open(input_csv, 'r', newline='') as csvfile:
    # Create a CSV reader object
    csv_reader = csv.reader(csvfile)

    # Skip header row.
    next(csv_reader)

    # Empty list to add the submitted for values to.
    submitted_for_set = set()
    shot_list_set = set()
    asset_set = set()
    other_set = set()

    # Go through each row in the CSV file and print the fifth column.
    for row in csv_reader:
        row_count += 1
        submitted_for_values = row[4]
        shot_list_for_values = row[1]
        asset_list_for_values = row[1]
        other_list_values = row[1]
        submitted_for_set.add(submitted_for_values.title())
        if '_' in shot_list_for_values and shot_list_for_values[:3].isdigit():
            seq_count += 1
            shot_list_set.add(shot_list_for_values.split('_')[1])
        elif shot_list_for_values == "n/a":
            other_count += 1
            other_set.add(other_list_values)
        else:
            asset_count += 1
            asset_set.add(asset_list_for_values)

# Convert the set of unique values back to a list
submitted_for_list = list(submitted_for_set)
shot_list = list(shot_list_set)
asset_list = list(asset_set)
other_list = list(other_set)

# Count variables of different lists converted for string.
version_number = str(row_count)
seq_number = str(seq_count)
asset_number = str(asset_count)
other_number = str(other_count)

# Iterate through submitted_for_list and convert items with 2 or 3 letters to uppercase.
for i in range(len(submitted_for_list)):
    # Check if the length of the item is 2 or 3 letters
    if 2 <= len(submitted_for_list[i]) <= 3:
        # Convert the item to uppercase
        submitted_for_list[i] = submitted_for_list[i].upper()

# String for if there's 1 submitted for, 1 sequence and 1 version.
if len(submitted_for_list) == 1 and len(shot_list) == 1 and row_count == 1:
    submitted_string = "This has been submitted for " + submitted_for_list[0] + " (" + shot_list[0] + " sequence)."
    print(submitted_string, end=" ")
# String for if there's more than 1 submitted for, 1 sequence and more than one 1 version.
elif len(submitted_for_list) > 1 and len(shot_list) == 1 and row_count > 1:
    submitted_string = "These have been submitted for " + ", ".join(submitted_for_list[:-1])
    submitted_string += " and " + submitted_for_list[-1] + "."
    shot_string = " " + seq_number + " versions included for the " + shot_list[0] + " sequence."
    print(submitted_string + shot_string, end=" ")
# String for if there's 1 submitted for, more than 1 sequence and more than one 1 version.
elif len(submitted_for_list) == 1 and len(shot_list) > 1 and row_count > 1:
    submitted_string = "These have been submitted for " + submitted_for_list[0] + ". "
    shot_string = seq_number + " versions included for sequences: " + ", ".join(shot_list[:-1])
    shot_string += " and " + shot_list[-1] + "."
    print(submitted_string + shot_string, end=" ")
# string for if there's 1 submitted for, 1 sequence but multiple versions.
elif len(submitted_for_list) == 1 and len(shot_list) == 1 and row_count > 1:
    submitted_string = "These " + seq_number + " versions have been submitted for " + submitted_for_list[0] + " (" + shot_list[0] + " sequence)."
    print(submitted_string, end=" ")
elif len(submitted_for_list) >= 2 and len(shot_list) >= 2 and row_count >= 2:
    submitted_string = "These have been submitted for " + ", ".join(submitted_for_list[:-1])
    submitted_string += " and " + submitted_for_list[-1] + "."
    shot_string = " " + seq_number + " versions included for sequences: " + ", ".join(shot_list[:-1])
    shot_string += " and " + shot_list[-1] + "."
    print(submitted_string + shot_string, end=" ")
# If there is 1 submitted for but no sequence but at least 1 and above versions.
elif len(submitted_for_list) == 1 and len(shot_list) == 0 and row_count >= 1:
    submitted_string = "These have been submitted for " + submitted_for_list[0] + "."
    print(submitted_string, end=" ")

# If statement for Assets present.
if len(asset_list) > 1:
    asset_string = asset_number + " Asset versions for: " + ", ".join(asset_list[:-1])
    asset_string += " and " + asset_list[-1] + "."
    print(asset_string, end=" ")
elif asset_count == 1:
    asset_string = asset_number + " Asset version for: " + asset_list[0] + "."
    print(asset_string, end=" ")
elif asset_count >= 2:
    asset_string = asset_number + " Asset versions for: " + asset_list[0] + "."
    print(asset_string, end=" ")
else:
    asset_string = ""

# Create a sentence for other variables if they exist.
if other_count > 1:
    other_string = other_number + " Other versions for: " + ", ".join(other_list[:-1])
    other_string += " and " + other_list[-1] + "."
    print(other_string)
elif other_count == 1:
    other_string = other_number + " Other version for: " + other_list[0] + "."
    print(other_string)
else:
    other_string = ""
