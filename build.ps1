
param (
    [string]$BumpLevel = "",  # Optional: major, minor, patch
    [string]$OnlyRun = ""     # Optional: pdf, epub, manuscript
)

Echo "`nLet's make a book!"

Echo "`n>>> Gathering files"
[array]$Files = Get-ChildItem .\chapters | Select -expand name
$FileString = ""
$words = 0

Echo "`n>>> Concatenating filenames and counting words"
ForEach ($File in $Files) {
    $FileString="$($FileString).\chapters\$File "
    $words+=Get-Content ".\chapters\$File" | Measure-Object -Word | select -expand Words
}

Echo "    There are $words words."
Echo "    File List: $FileString"

$buildcommand = ""
$nextbuild = "preview"

Echo "`n>>> Determining build number..."

if ( $BumpLevel ) {
    $buildtags = git tag -l "v*" --sort=-v:refname
    $prevbuild = (((($buildtags -split '\n')[0]) -split 'v')[1]) -split '\.'
    $major = $prevbuild[0] -as [int]
    $minor = $prevbuild[1] -as [int]
    $patch = $prevbuild[2] -as [int]

    switch ($BumpLevel) {
        "major" {
            $major++
            $minor=0
            $patch=0
            Break
        }
        "minor" {
            $minor++
            $patch=0
            Break
        }
        "patch" {
            $patch++
            Break
        }
        Default {
            "`nERROR: bad bump level. Should be one of: major, minor, patch`n"
            exit
        }
    }

    $nextbuild = "$major.$minor.$patch"
    Echo "    This will be build: $nextbuild"
    $buildcommand = "--metadata=build:$nextbuild"

} else {

    $currenttag = git tag --points-at HEAD
    $count = ($currenttag -split '\n').Length
    if ( $count -gt 1 ) {
        Echo "`nWARNING: More than one tag reference, generating 'preview' build"
    } elseif ( $currenttag -match '^v\d+\.\d+\.\d+$' ) {
        $nextbuild = ($currenttag -split 'v')[1]
        echo "    Using current tag: $nextbuild"
        $buildcommand = "--metadata=build:$nextbuild"
    } else {
        Echo "`nWARNING: Tag reference is not a valid build, generating 'preview' build"
    }
}

$baseconfig = Get-Content .\config-common.yaml

# Need to debug?
# change the "-o .\output\..." options below from whatever format they are to ".\output\book.html" to see interim HTML output before final doc generation

if ( $OnlyRun -eq "" -or $OnlyRun -eq "pdf" ) {
    $pdfconfig = Get-Content .\config-pdf.yaml
    $PdfCommand = "pandoc -s -d tmp-config.yaml -o .\output\book-$nextbuild.pdf $buildcommand"
    Echo "`n>>> Generating PDF file with:  $PdfCommand"
    ($baseconfig + $pdfconfig) | Set-Content ".\tmp-config.yaml"
    Invoke-Expression "$PdfCommand $FileString"
    del .\tmp-config.yaml
}

if ( $OnlyRun -eq "" -or $OnlyRun -eq "epub" ) {
    $epubconfig = Get-Content .\config-epub.yaml
    $EpubCommand = "pandoc -d tmp-config.yaml -o .\output\book-$nextbuild.epub $buildcommand"
    Echo "`n>>> Generating epub file with:  $EpubCommand"
    ($baseconfig + $epubconfig) | Set-Content ".\tmp-config.yaml"
    Invoke-Expression "$EpubCommand $FileString"
    del .\tmp-config.yaml
}

if ( $OnlyRun -eq "" -or $OnlyRun -eq "manuscript" ) {
    $manuscriptConfig = Get-Content .\config-manuscript.yaml
    ($baseconfig + $manuscriptConfig) | Set-Content ".\tmp-config.yaml"

    Echo "`n>>> Generating manuscript file"

    $manuscriptCommand = "pandoc -s -d tmp-config.yaml -o .\output\tmp-manuscript.md"
    Echo "    generating intermediary markdown:"
    Echo "    $manuscriptCommand"
    Invoke-Expression "$manuscriptCommand $FileString"

    $manuscriptCommand = "pandoc -o .\output\manuscript-$nextbuild.docx --reference-doc template-manuscript.docx -f markdown -t docx .\output\tmp-manuscript.md"
    Echo "    generating docx manuscript:"
    Echo "    $manuscriptCommand"
    Invoke-Expression "$manuscriptCommand"
    
    del .\output\tmp-manuscript.md
    del .\tmp-config.yaml
}


if ( $BumpLevel ) {
    Echo "`n>>> Tagging new build: git tag build-$nextbuild"
    git tag "v$nextbuild"
    git push origin "v$nextbuild"
}

Echo "`nAll done!`n"
