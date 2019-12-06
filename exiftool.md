## delete duplicates
fdupes -rdN .


## rename with model
exiftool -d %Y%m%d_%H%M%S%%-c '-filename<$datetimeoriginal-${model;}-${filesize;}.%e’ -r .
exiftool -v -d %Y%m%d_%H%M%S '-Filename<${datetimeoriginal}${subsectimeoriginal;$_.=0 x(3-length)}.%e' -if ‘(not $subsectimeoriginal)’  .

## set thumbnail image
exiftool '-ThumbnailImage<=thumb.jpg' dst.jpg

## move to model directories
exiftool '-directory<$model' -r .

## move to dated folders
exiftool '-Directory<DateTimeOriginal' -d %Y/%m -r .

## set datetimeoriginal to other dates if no original
exiftool \
'-datetimeoriginal<createdate' \
'-datetimeoriginal<modifydate' \
'-datetimeoriginal<filemodifydate' \
-if '(not $datetimeoriginal or ($datetimeoriginal eq "0000:00:00 00:00:00"))' -r .


## final naming convention
exiftool \
'-FileName<${DateTimeOriginal}.%e' \
'-FileName<${DateTimeOriginal}_${Model;tr/ /_/;s/__+/_/g}.%e' \
'-FileName<${DateTimeOriginal}${subsectimeoriginal;$_.=0 x(3-length)}_${Model;tr/ /_/;s/__+/_/g}.%e' \
-d %Y-%m-%d_%H-%M-%S%%-c \
-r .

