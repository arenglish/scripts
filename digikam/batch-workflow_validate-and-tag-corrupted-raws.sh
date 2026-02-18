#!/usr/bin/env bash

logfile="/Users/austinenglish/digikam/batchlog.txt"
echo "begin batch" > "$logfile"

in_file=$INPUT
out_file=$OUTPUT

filename=$(basename "$in_file")
echo "INPUT: $in_file \n filename: $filename" >> "$logfile"

FILE_TYPE_REGXP="CR2|cr2"

# Exit gracefully if $INPUT is not desired file type
if [[ ! "${in_file##*.}" =~ $FILE_TYPE_REGXP ]]; then
    echo "Skipping: $in_file extension does not match $FILE_TYPE_REGXP" >> "$logfile"
    exit 0
fi

FAILED_TAG="Admin/Corrupted"
DNG_DIR="/Users/austinenglish/tmp" 
FAILED_LIST="/Users/austinenglish/digikam/failed_conversions.txt"
DNG_CONVERTER="/Applications/Adobe DNG Converter.app/Contents/MacOS/Adobe DNG Converter"
EXIFTOOL="/usr/local/bin/exiftool"

echo "in_file: ${in_file}" >> "$logfile"
echo "OUTPUT_DIR: $DNG_DIR" >> $logfile


conversion_result=$("$DNG_CONVERTER" -fl -mp -d "$DNG_DIR" "$in_file" 2>&1)
EXIT_CODE=$?

basename="${filename%.*}";
dng_file="$DNG_DIR/$basename.dng";
echo "output file: $dng_file" >> "$logfile";

if [ $EXIT_CODE -ne 0 ] || [ ! -f "$dng_file" ]; then
    echo "❌ Failed: $filename" >> "$logfile"
    echo "$in_file" >> "$FAILED_LIST"
    echo "$conversion_result" >> "$logfile"

    if [ $EXIT_CODE -ne 0 ]; then
        echo "ERROR_CODE: $EXIT_CODE" >> "$logfile"
    else
        echo "output file not found: \"$dng_file\""
    fi

    XMP_SIDECAR="$in_file.xmp"
    echo "XMP_SIDECAR: $XMP_SIDECAR" >> "$logfile"

    if [ ! -f "$XMP_SIDECAR" ]; then
        echo "Creating XMP sidecar"
        "$EXIFTOOL" -o %d%f.%e.xmp $in_file >> "$logfile" 2>&1
    fi

    echo "Checking for existing tag: $FAILED_TAG" >> "$logfile"
    Check if the tag already exists
    found_tag=$("$EXIFTOOL" -XMP:Subject "$XMP_SIDECAR" | grep -q "$FAILED_TAG")

    echo "found_tag: $found_tag" >> "$logfile"

    if [ ! $found_tag ]; then
        echo "Tagging $filename with $FAILED_TAG" >> "$logfile";
        # Write tag to XMP sidecar
        "$EXIFTOOL" -overwrite_original -XMP:Subject+="$FAILED_TAG" "$XMP_SIDECAR" >> "$logfile" 2>&1;
        echo "Tagged $filename with $FAILED_TAG" >> "$logfile";
    else
        echo "$filename already has tag $FAILED_TAG" >> "$logfile"
    fi
else
    echo "✅ Valid: $filename" >> "$logfile"
fi

rm "$dng_file" >> "$logfile" 2>&1

cp "$in_file" "$out_file"

exit $?