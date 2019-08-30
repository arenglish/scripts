target_flag=0
source_flag=0
rename_flag=0


while getopts "rs:t:" opt; do
  case ${opt} in
    t )
      target_flag=1
      TARGET="`eval echo ${OPTARG//>}`"
      ;;
    r )
      rename_flag=1
      ;;
    s )
      source_flag=1
      SOURCE="`eval echo ${OPTARG//>}`"
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

if [[ $target_flag -eq 0 ]] && [[ $source_flag -eq 0 ]] && [[ $rename_flag -eq 0 ]]
then
    echo "no options given"
    exit 1
fi

if [ $source_flag -eq 0 ]; then
    echo "must enter source directory...\n"
    exit 1
fi

if [ ! -d $SOURCE ]; then
    echo "source directory doesn't exist... $SOURCE\n"
    exit 1
fi
if [[ $target_flag -eq 1 ]] && [[ ! -d $TARGET ]]; then
    echo "target directory doesn't exist... $TARGET\n"
    exit 1
fi

if [ $rename_flag -eq 1 ]
then
    echo "making sure datetimeoriginal is set..."

    exiftool \
    '-datetimeoriginal<createdate' \
    '-datetimeoriginal<modifydate' \
    '-datetimeoriginal<filemodifydate' \
    -ext CR2 -ext DNG -ext JPG -ext MP4 -ext MOV -ext WAV \
    -if '(not $datetimeoriginal or ($datetimeoriginal eq "0000:00:00 00:00:00"))' \
    -r \
    "$SOURCE"

    echo "renaming media..."

    exiftool \
    -d %Y-%m-%d_%H-%M-%S \
    '-FileName<${DateTimeOriginal}%-c.%le' \
    '-FileName<${DateTimeOriginal}_${Model;tr/ /_/;s/__+/_/g}%-c.%le' \
    '-FileName<${DateTimeOriginal}${subsectimeoriginal;$_.=0 x(3-length)}_${Model;tr/ /_/;s/__+/_/g}%-c.%le' \
    -ext CR2 -ext DNG -ext JPG -ext MP4 -ext MOV -ext WAV \
    -r "$SOURCE"
fi

if [ $target_flag -eq 1 ]; then
    echo "exporting images to $TARGET\n"

    exiftool '-Directory<DateTimeOriginal' -d "$TARGET/%Y/%m_%B" \
    -ext CR2 -ext DNG -ext JPG -ext MP4 -ext MOV -ext WAV \
    -r -i "$TARGET" \
    "$SOURCE"
fi
