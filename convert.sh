#!/bin/bash

# Current working directory
source_dir=$(pwd)

# Destination directory
dest_dir="compressed"

# Failed compression directory
failed_dir="failed"

# Create the destination directory if it doesn't exist
mkdir -p "$dest_dir"

# Create the failed directory if it doesn't exist
mkdir -p "$failed_dir"

# Check if there are any .mp4 files in the source directory
shopt -s nullglob
mp4_files=("$source_dir"/*.mp4)
shopt -u nullglob

if [ ${#mp4_files[@]} -gt 0 ]; then
  # Loop through each .mp4 file and compress it using ffmpeg
  for file in "${mp4_files[@]}"; do
    # Extracting the file name without extension
    file_name=$(basename "$file" .mp4)

    # Compress, scale down, pad, and scale to 360p preserving aspect ratio using ffmpeg
    ffmpeg -i "$file" -c:v libx264 -crf 27 -vf "scale=-1:360,pad=ceil(iw/2)*2:ceil(ih/2)*2" -c:a aac -strict experimental -threads 1 "$dest_dir"/"$file_name"_compressed.mp4

    # Check the exit status of the ffmpeg command
    if [ $? -eq 0 ]; then
      # Compression was successful, optionally remove the original .mp4 file
      # Uncomment the line below to enable the removal
        rm "$file"
      echo "Compression and scaling successful: $file_name"
    else
      # Compression failed, move the video to the failed directory
      mv "$file" "$failed_dir"
      echo "Compression failed, moved to '$failed_dir': $file_name"
    fi
  done

  echo "Compression and scaling complete. Compressed files are in the '$dest_dir' directory."
else
  echo "No .mp4 files found in the current working directory."
fi

