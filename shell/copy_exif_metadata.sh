#!/bin/bash
# A script to write metadata from source files to transcoded target files

# Check if the source and target directories are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <source_directory> <target_directory>"
  exit 1
fi

# Source and target directories
SOURCE_DIR="$1"
TARGET_DIR="$2"

# Find all MOV and mov files in the source directory
find "$SOURCE_DIR" -type f \( -iname "*.MOV" -o -iname "*.mov" \) | while read -r srcfile; do
  # Extract the filename without the extension
  filename=$(basename -- "$srcfile")
  filename="${filename%.*}"

  # Define the corresponding target files with various extensions
  tgtfile_upper_mp4="$TARGET_DIR/$filename.MP4"
  tgtfile_lower_mp4="$TARGET_DIR/$filename.mp4"
  tgtfile_upper_mov="$TARGET_DIR/$filename.MOV"
  tgtfile_lower_mov="$TARGET_DIR/$filename.mov"

  # Determine the existing target file
  if [ -f "$tgtfile_upper_mp4" ]; then
    tgtfile="$tgtfile_upper_mp4"
  elif [ -f "$tgtfile_lower_mp4" ]; then
    tgtfile="$tgtfile_lower_mp4"
  elif [ -f "$tgtfile_upper_mov" ]; then
    tgtfile="$tgtfile_upper_mov"
  elif [ -f "$tgtfile_lower_mov" ]; then
    tgtfile="$tgtfile_lower_mov"
  else
    echo "Target file for $filename not found"
    continue
  fi

    echo "========================================"
    echo "Reading metadata from $srcfile"

    # Extract the capture dates
    capturedate=$(exiftool -DateTimeOriginal -s3 "$srcfile")
    filecreatedate=$(exiftool -FileCreateDate -s3 "$srcfile")
    createdate=$(exiftool -CreateDate -s3 "$srcfile" -api QuickTimeUTC)
    creationdate=$(exiftool -CreationDate -s3 "$srcfile")
    mediacreatedate=$(exiftool -MediaCreateDate -s3 "$srcfile")
    mediamodifydate=$(exiftool -MediaModifyDate -s3 "$srcfile")
    trackcreatedate=$(exiftool -TrackCreateDate -s3 "$srcfile")
    trackmodifydate=$(exiftool -TrackModifyDate -s3 "$srcfile")
    modifydate=$(exiftool -ModifyDate -s3 "$srcfile")
    echo "Capture Date: $capturedate"
    echo "File Create Date: $filecreatedate"
    echo "Create Date: $createdate"
    echo "Creation Date: $creationdate"
    echo "Media Create Date: $mediacreatedate"
    echo "Media Modify Date: $mediamodifydate"
    echo "Track Create Date: $trackcreatedate"
    echo "Track Modify Date: $trackmodifydate"
    echo "Modify Date: $modifydate"
    echo "----------"

    # Extract the Camera details
    make=$(exiftool -Make -s3 "$srcfile")
    model=$(exiftool -Model -s3 "$srcfile" -ee)
    cameramodel=$(exiftool -CameraModel -s3 "$srcfile" -ee)
    cameralensmodel=$(exiftool -CameraLensModel -s3 "$srcfile" -ee)
    echo "Make: $make"
    echo "Model: $model"
    echo "Camera Model: $cameramodel"
    echo "Camera Lens Model: $cameralensmodel"
    echo "----------"

    # Extract GPS details
    gpsposition=$(exiftool -GPSPosition -s3 "$srcfile")
    gpscoordinates=$(exiftool -GPSCoordinates -s3 "$srcfile")
    gpslongitude=$(exiftool -GPSLongitude -s3 "$srcfile")
    gpslatitude=$(exiftool -GPSLatitude -s3 "$srcfile")
    gpsaltitude=$(exiftool -GPSAltitude -s3 "$srcfile")
    echo "GPS Position: $gpsposition"
    echo "GPS Coordinates: $gpscoordinates"
    echo "GPS Longitude: $gpslongitude"
    echo "GPS Latitude: $gpslatitude"
    echo "GPS Altitude: $gpsaltitude"

    # Alternative 1: Write all tags to target file
    echo "Write TagsFromFile (All)"
    exiftool -TagsFromFile "$srcfile" -All:All "$tgtfile"
    # Adjust the capture date (UTC fix)
    echo "Write CreateDate (UTC fix)"
    exiftool -CreateDate="$createdate" -CreationDate="$createdate" "$tgtfile"

    # Alternative 2: Write specific tags
    #exiftool -DateTimeOriginal="$capturedate" \
    #-FileCreateDate="$filecreatedate" \
    #-CreateDate="$createdate" \
    #-CreationDate="$creationdate" \
    #-MediaCreateDate="$mediacreatedate" \
    #-MediaModifyDate="$mediamodifydate" \
    #-TrackCreateDate="$trackcreatedate" \
    #-TrackModifyDate="$trackmodifydate" \
    #-ModifyDate="$modifydate" \
    #-Make="$make" \
    #-Model="$model" \
    #-XMP:Model="$model" \
    #-CameraModel="$cameramodel" \
    #-Lens="$cameralensmodel" \
    #-GPSPosition="$gpsposition" \
    #-GPSCoordinates="$gpscoordinates" \
    #-GPSLongitude="$gpslongitude" \
    #-GPSLatitude="$gpslatitude" \
    #-GPSAltitude="$gpsaltitude" \
    #"$tgtfile"

    # Delete the temporary file
    rm "$tgtfile"_original
    echo "Wrote metadata to $tgtfile"
    echo "========================================"

done
