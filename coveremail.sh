#!/bin/bash

# Change working directory.
cd /lucas/ilm/home/mhartney/Documents/email_drafts/cover_email/

# Find outgoing folder.
input_folder=$(zenity --file-selection --title FOO --directory --filename /lucas/ilm/show/paradox/staging/outgoing/to_client/)

# Remove trailing slash if exists from filepath.
if [[ $input_folder == */ ]]; then
  # Remove the trailing slash
  input_path="${input_folder%/}"
else
  input_path="$input_folder"
fi

# Variables for email.
PKG=$(echo $input_path | rev | cut -d '/' -f 1 | rev)
LIST=$(seqtree "$input_path" | sed '1d' | grep -Ev '\.csv$')
MONTH=$(date +"%Y.%m") ; DAY=$(date +"%Y.%m.%d") ; DATE=$(date +"%Y%m%d")

# This program will determine if this input path is a simple MOVs send for review, a tech check send or
# a send for Harbor. It will generate the email blurb I need for both and then all else failing will
# summarise what the package is or give me an option to input note.

# Use this expression pattern to check if the package is a Harbor send.
pattern="^[0-9]{8}_pdx_ilm_0[0-9]{2}$"
folder_name=$(basename "$input_path")

if [[ "$folder_name" =~ $pattern ]]; then
  echo "Finals send to Harbor."
fi

# Use find to locate the CSV file
csv_file_path=$(find "$input_path" -type f -name "*.csv" -print -quit)

# Declare an array to store unique, capitalized file extensions
capitalized_extensions=()

# Declare a flag to indicate if .exr files are found
exr_files_found=false

# Function to search for .exr files in a directory recursively
function search_exr_files {
  local directory="$1"
  if [[ -n $(find "$directory" -type f -name "*.exr") ]]; then
    exr_files_found=true
  fi
}

# Check for file types inside the folder.
for file in "$input_path"/*; do
  # Check if the item is a file (not a directory)
  if [ -f "$file" ]; then
    # Extract the file extension using parameter expansion
    extension="${file##*.}"
    # Exclude CSV files from the list and create an array of files.
    if [ "$extension" != "csv" ] && [ "$extension" != "$file" ] && [[ ! "${capitalized_extensions[@]}" =~ "${extension^^}" ]]; then
      capitalized_extensions+=("${extension^^}")
    fi
  elif [ -d "$file" ]; then
    # If it's a directory, check for .exr files inside.
    search_exr_files "$file"
  fi  
done  

# Construct the string based on unique, capitalized file extensions
file_extensions_string=""
for extension in "${capitalized_extensions[@]}"; do
    file_extensions_string+=" $extension and"
done

# Add .exr files to the string if found
if [ "$exr_files_found" == true ]; then
  file_extensions_string+=" EXR and"
fi

# Remove the trailing "and" and add it to the final string
file_extensions_string="${file_extensions_string% and}"
result="This package contains$file_extensions_string files."

# Check if the string "ILM Tech Check Approved" is present in the CSV file
if [ "$exr_files_found" == true ] && [ -f "$csv_file_path" ] && grep -q "Tech Check Approved" "$csv_file_path" ; then
  echo "Tech Check send for final submissions."
  send_type=$(echo "final submissions. MOVs were sent in the preceding package.")
elif [ -f "$csv_file_path" ] && grep -q "Tech Check Approved" "$csv_file_path" ; then
  echo "Tech Check send for final submissions."
  send_type=$(echo "final submissions. The corresponding EXR files will follow in the next delivery.")
elif [ -f "$csv_file_path" ] && grep -q "Repo Approval" "$csv_file_path" ; then
  echo "Picture Match versions"
  send_type=$(echo "Picture Match versions.")
elif [ -f "$csv_file_path" ] && grep -q "Respeed Approval" "$csv_file_path" ; then
  send_type=$(echo "Picture Match versions.")
elif [ -f "$csv_file_path" ] && grep -q "Version Zero" "$csv_file_path" ; then
  echo "Version Zero"
  send_type=$(echo "Version Zero.")
elif [[ "$folder_name" =~ $pattern ]] ; then
  send_type=$(echo "final submissions.")
else
  echo "Submissions for review."
  send_type=$(echo "review.")
fi

# Print the final string
echo "$result"

# Copy Excel for email.
if [ -f $csv_file_path ] ; then
  cp $csv_file_path /home/mhartney/Documents/email_drafts/cover_email/
fi


# Get csv message from python script.
csvReader_message=$(python3 /home/mhartney/PycharmProjects/pythonProject/csvReader.py "$csv_file_path")  

# Generate email.
echo "This package contains$file_extensions_string files. $csvReader_message" 
email_message=$(echo "This package contains$file_extensions_string files. $csvReader_message")
SIZE=$(du -sh --apparent-size "$input_path" | cut -f1)

generate_email=$(echo -e "Hello,\n\nThe following package has been uploaded to Falcon. Submission notes can be found in the excel attached or within the package.\n\n$email_message\n\nPackage Name: $PKG\nPassword: S1thSt@rDu5t!\n\nFile List:\n$LIST\n\nSize of Package:\n$SIZE\n\nPlease let me know if there are any issues.\n\nThanks!\nMax\n\nMax Hartney | Production Assistant | Industrial Light & Magic | London")
echo "$generate_email"

# Save email for sending.
echo "$generate_email" > draft1.txt

# Get package descripion.
if [ "$send_type" == "final submissions. MOVs were sent in the preceding package." ] ; then 
  echo "Subject: Final Submission EXRs"
  DESC=$(echo "Final Submission EXRs")
elif [ "$send_type" == "final submissions. The corresponding EXR files will follow in the next delivery." ] ; then
  echo "Subject: Final Submission MOVs"
  DESC=$(echo "Final Submission MOVs") 
elif [ "$send_type" == "review." ] ; then
  echo "Subject: Submissions for Review"
  DESC=$(echo "Submissions for Review")
else
  echo -e "\n\n" ; read -p "Email Subject: " DESC
fi

# Send email to me.
SUB="PDX ILM | $DESC | Submission $PKG"
mail -s "$SUB" -a /home/mhartney/Documents/email_drafts/cover_email/$PKG.csv mhartney@ilm.com < draft1.txt
echo -e "\nEmail draft sent to your inbox.\n"

# Option to send to Client etc.
echo -e "\nDo you want to send to client? y/n\n" ; read VAR1

if [[ "$VAR1" == "y" ]]; then
  echo "Sending to Client."
  SUB="PDX ILM | $DESC | Submission $PKG"
  mail -s "$SUB" -a /home/mhartney/Documents/email_drafts/cover_email/$PKG.csv -c "ilm-paradox@ilm.com mhartney@ilm.com" "paradoxvfx@lflprod.com" < draft1.txt 
  echo -e "\nEmail sent!"
else
  echo "Cancelled."
fi

# Spring Cleaning.
cd /lucas/ilm/home/mhartney/Documents/email_drafts/cover_email/
rm *.txt
rm *.csv

