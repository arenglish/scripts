Function Rename-Photos {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true,
                    HelpMessage="Source file or directory")]
        [string]$path
    )

    BEGIN {
        $resolvedPath = Resolve-Path $path
        if ((-not(Test-Path -Path $resolvedPath -PathType Leaf)) -and (-not(Test-Path -Path $resolvedPath))) {
            throw "$files does not exist"
        }
    }
    PROCESS {
        $filetypes="-ext CR2 -ext DNG -ext JPG -ext MP4 -ext MOV -ext WAV -ext PNG -ext TIFF"
        $resolvedPath = Resolve-Path $path

        Write-Host "Renaming $($resolvedPath)"
        exiftool `
            -d %Y-%m-%d_%H-%M-%S `
            '-FileName<${DateTimeOriginal}.%le' `
            '-FileName<${DateTimeOriginal}_${Model;tr/ /_/;s/__+/_/g}.%le' `
            '-FileName<${DateTimeOriginal}${subsectimeoriginal;$_.=0 x(3-length)}_${Model;tr/ /_/;s/__+/_/g}.%le' `
            $filetypes `
            -r $resolvedPath
    }
    END {
    }
}
