Function Move-Photos {
    [CmdletBinding()]

    param(
        [
            Parameter(Mandatory=$true, HelpMessage="Directory of photos to move")
        ]
        [string]$srcPath,
        [
            Parameter(Mandatory=$true, HelpMessage="Directory to move photos to")
        ]
        [string]$moveTo,
        [
            Parameter(Mandatory=$false, HelpMessage="Organize photos by either 'date', 'model', or 'none[default]'"),
            ValidateSet("date", "model", "none")
        ]
        [string]$organizeBy
    )

    BEGIN {
        $resolvedPath = Resolve-Path $moveTo
        if ((-not(Test-Path -Path $resolvedPath -PathType Leaf)) -and (-not(Test-Path -Path $resolvedPath))) {
            throw "$files does not exist"
        }
    }
    PROCESS {
        $filetypes="-ext CR2 -ext DNG -ext JPG -ext MP4 -ext MOV -ext WAV -ext PNG -ext TIFF"
        $organizeOptions = "date", "model"
        $moveToResolve = Resolve-Path $moveTo

        Write-Host "Moving photos to $($resolvedPath)"

        if ($organizeBy -eq "date") {
            Write-Host "Organizing photos by date"

            exiftool `
            '-Directory<DateTimeOriginal' -d "$($moveToResolve)/%Y/%m_%B" `
            $filetypes `
            $NAME_AS_COPY_IF_EXISTS `
            -r -i $moveToResolve `
            $srcPath
        }
        if ($organizeBy -eq "model") {
            Write-Host "Organizing photos by model"

            exiftool `
            '-directory<'"$($moveToResolve)"'/$model' \
            $filetypes \
            -r -i $moveToResolve \
            $srcPath
        }
        if (!$organizeBy) {
            exiftool `
            -directory=$moveTo `
            $filetypes `
            -r -i $moveTo `
            $srcPath
        }
    }
    END {
    }
}
