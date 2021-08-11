Get-ChildItem "./" -Filter *.mov -recurse | Foreach-Object {
	try {
        $newFilePath = "compressed/$($_.BaseName).mp4"
        $newFilePath = "compressed/$($_.BaseName).mp4"
        $newRenamedFilePath = $newFilePath -replace '(.*)_(\d\d-\d\d-\d\d)(...)_Canon_(.*).mp4','$1_$2_Canon_$4.mp4'

        if (-not(Test-Path -Path $newRenamedFilePath -PathType Leaf)) {
                Write-Host "CREATING FILE $($newFilePath)"

                #ffmpeg -i  "$($_.FullName)" -map_metadata 0 -preset slow -crf 17 -hide_banner -loglevel error $newFilePath
                #exiftool -tagsFromFile "$($_.FullName)" -extractEmbedded -overwrite_original -v $newFilePath
         }
         else {
            Write-Host "FILE $($newRenamedFilePath) ALREADY EXISTS"
         }

	}
	catch {
		Write-Host "Error occurred on $($_.FullName)"
		Write-Host $_
	}

}
