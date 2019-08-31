#!/bin/bash
target_flag=0
target_by_date_flag=0
target_by_model_flag=0
source_flag=0
date_flag=0
rename_flag=0
model_flag=0
model_force_flag=0
error_flag=0

FILETYPES="-ext CR2 -ext DNG -ext JPG -ext MP4 -ext MOV -ext WAV -ext PNG -ext TIFF"
NAME_AS_COPY_IF_EXISTS='-FileName<$basename%-c.%le'
GET_CONFIG_FILE="-config exiftool.config"

while getopts "drm:s:t:T:M:D:" opt; do
  case ${opt} in
    t )
      # Moves images to specified target directory
      target_flag=1
      TARGET="`eval echo ${OPTARG//>}`"
      ;;
    T )
      # Moves images to specified target directory under model directories
      target_by_model_flag=1
      TARGET="`eval echo ${OPTARG//>}`"
      ;;
    D )
      # Moves images to specified target directory under dated directories
      target_by_date_flag=1
      TARGET="`eval echo ${OPTARG//>}`"
      ;;
    d )
      # Writes datetimeoriginal tag from other date tags if source datetimeoriginal does not exist
      date_flag=1
      ;;
    r )
      rename_flag=1
      ;;
    s )
      source_flag=1
      SOURCE="`eval echo ${OPTARG//>}`"
      ;;
    m )
      # Writes provided model name to model tag if model tag is empty or doesn't exist
      model_flag=1
      MODEL="`eval echo ${OPTARG//>}`"
      ;;
    M )
      # Overwrites model tag with provided model name
      model_force_flag=1
      MODEL="`eval echo ${OPTARG//>}`"
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

if [[ $target_by_date_flag -eq 0 ]] && [[ $target_flag -eq 0 ]] && [[ $target_by_model_flag -eq 0 ]] && [[ $source_flag -eq 0 ]] && [[ $rename_flag -eq 0 ]] && [[ $model_flag -eq 0 ]] && [[ $model_force_flag -eq 0 ]] && [[ $date_flag -eq 0 ]]
then
    echo "no options given"
    exit 1
fi

if [ $source_flag -eq 0 ]; then
    echo "must enter source directory..."
    exit 1
fi

if [[ ! -d $SOURCE ]] && [[ ! -f $SOURCE ]]; then
    echo "source file or directory doesn't exist... $SOURCE"
    exit 1
fi
if ([[ $target_flag -eq 1 ]] || [[ $target_by_date_flag -eq 1 ]] || [[ $target_by_model_flag -eq 1 ]]) && [[ ! -d $TARGET ]]; then
    echo "target directory doesn't exist... $TARGET"
    exit 1
fi

if ([[ $rename_flag -eq 1 ]] || [[ $date_flag -eq 1 ]]) && ([[ $model_flag -eq 1 ]] || [[ $model_force_flag -eq 1 ]]); then
    echo "Run tag altering commands first, delete originals, then rename.  Renaming the modified photos before deleting original copies will prevent 'exiftool -delete_original' from being able to find the originals and delete them."
    exit 1
fi

if [ $model_flag -eq 1 ]
then
  echo "writing model name to photos without model tag: $MODEL..."
  exiftool \
  $GET_CONFIG_FILE \
  -model="$MODEL" \
  $FILETYPES \
  -if '(not $model)' \
  -r \
  "$SOURCE"
fi

if [ $model_force_flag -eq 1 ]
then
  echo "overwriting photo model tags with: $MODEL..."
  exiftool \
  $GET_CONFIG_FILE \
  -model="$MODEL" \
  $FILETYPES \
  -r \
  "$SOURCE"
fi

if [ $date_flag -eq 1 ]
then
    echo "making sure datetimeoriginal is set..."
    echo "Source: $SOURCE"

    exiftool \
    $GET_CONFIG_FILE \
    '-datetimeoriginal<createdate' \
    '-datetimeoriginal<modifydate' \
    '-datetimeoriginal<filemodifydate' \
    $FILETYPES \
    -if '(not $datetimeoriginal or ($datetimeoriginal eq "0000:00:00 00:00:00"))' \
    -r \
    "$SOURCE"
fi

if [ $rename_flag -eq 1 ]
then
    echo "renaming media..."

    exiftool \
    $GET_CONFIG_FILE \
    -d %Y-%m-%d_%H-%M-%S \
    '-FileName<${DateTimeOriginal}%-c.%le' \
    '-FileName<${DateTimeOriginal}_${Model;tr/ /_/;s/__+/_/g}%-c.%le' \
    '-FileName<${DateTimeOriginal}${subsectimeoriginal;$_.=0 x(3-length)}_${Model;tr/ /_/;s/__+/_/g}%-c.%le' \
    $FILETYPES \
    -r "$SOURCE"
fi

if [ $target_flag -eq 1 ]; then
    echo "moving images to $TARGET"

    exiftool \
    $GET_CONFIG_FILE \
    -directory=$TARGET \
    $FILETYPES \
    $NAME_AS_COPY_IF_EXISTS \
    -r -i "$TARGET" \
    "$SOURCE"
fi

if [ $target_by_date_flag -eq 1 ]; then
    echo "moving images to $TARGET by date"

    exiftool \
    $GET_CONFIG_FILE \
    '-Directory<DateTimeOriginal' -d "$TARGET/%Y/%m_%B" \
    $FILETYPES \
    -r -i "$TARGET" \
    "$SOURCE"
fi

if [ $target_by_model_flag -eq 1 ]; then
    echo "moving images to $TARGET by model name"

    exiftool \
    $GET_CONFIG_FILE \
    '-directory<'"$TARGET"'/$model' \
    $FILETYPES \
    -r -i "$TARGET" \
    "$SOURCE"
fi

exit
