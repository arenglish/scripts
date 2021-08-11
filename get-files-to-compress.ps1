Get-ChildItem "./" -Filter *.mov -recurse | Foreach-Object {
	try {
        $newFilePath = "compressed/$($_.BaseName).mp4"
        $newRenamedFilePath = $newFilePath -replace '(.*)_(\d\d-\d\d-\d\d)(...)_Canon_(.*).mp4','$1_$2_Canon_$4.mp4'
        Write-Host $newRenamedFilePath
	}
	catch {
		Write-Host "Error occurred on $($_.FullName)"
		Write-Host $_
	}

}
