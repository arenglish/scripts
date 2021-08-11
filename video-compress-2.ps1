Get-ChildItem . -Filter *23060_Canon_EOS_80D.mov -recurse |
Foreach-Object {
# 	ffmpeg -i $_.FullName -c copy -map_metadata 0 -map_metadata:s:v 0:s:v -map_metadata:s:a 0:s:a -crf 17 -preset slow -f ffmetadata metadata.txt
# 	Get-Content metadata.txt
	ffmpeg -i $_.FullName -map 0 -copy_unknown -map_metadata 0 -c copy -c:v h264 -crf 22 "compressed\$($_.BaseName).mp4"
}
