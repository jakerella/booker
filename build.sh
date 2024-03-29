#!/bin/bash

echo "Let's make a book!"

bumpLevel=""
onlyRun=""

if [ "$1" = "-BumpLevel" ]; then
    bumpLevel="$2"
elif [ "$3" = "-BumpLevel" ]; then
    bumpLevel="$4"
fi

if [ "$1" = "-OnlyRun" ]; then
    onlyRun="$2"
elif [ "$3" = "-OnlyRun" ]; then
    onlyRun="$4"
fi

echo ">>> Gathering files and counting words"

cat ./chapters/*.md > ./tmp-all.txt
counts=($(wc tmp-all.txt | grep -P '\d+' --only-matching))
echo "    There are ${counts[1]} words."
rm ./tmp-all.txt


buildcommand=""
nextbuild="preview"

echo ""
echo ">>> Determining build number..."

if [ "$bumpLevel" != "" ]; then
    buildtags=($(git tag -l "v*" --sort=-v:refname))

    IFS='.' read -r -a versionbits <<< "${buildtags[0]}"
    myString="${myString:1}"
    major="${versionbits[0]}"
    major="${major:1}"  # remove the "v" in front
    minor="${versionbits[1]}"
    patch="${versionbits[2]}"

    if [ "$bumpLevel" = "major" ]; then
        major=$(($major + 1))
        minor="0"
        patch="0"
        echo "major bump to: $major"
    elif [ "$bumpLevel" = "minor" ]; then
        minor=$(($minor + 1))
        patch="0"
        echo "minor bump to: $minor"
    elif [ "$bumpLevel" = "patch" ]; then
        patch=$(($patch + 1))
        echo "patch bump to: $patch"
    else
        echo "ERROR: Invalid level bump option (should be one of: major, minor, patch)"
        exit 1
    fi

    nextbuild="$major.$minor.$patch"
    echo "    This will be build: $nextbuild"
    buildcommand="--metadata=build:$nextbuild"

else
    currenttag=($(git tag --points-at HEAD))

    if [[ ${#currenttag[@]} > 1 ]]; then
        echo "WARNING: More than one tag reference, generating 'preview' build"

    elif [[ "${currenttag[0]}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        currenttag="${currenttag[0]}"
        nextbuild="${currenttag:1}"  # remove the "v" in front
        echo "    Using current tag: $nextbuild"
        buildcommand="--metadata=build:$nextbuild"

    else
        echo "WARNING: Current tag reference is not a valid build, generating 'preview' build"
    fi
fi


if [[ "$onlyRun" = "" || "$onlyRun" = "pdf" ]]; then
    echo ""
    echo ">>> Generating PDF file"
    cat config-common.yaml > tmp-config-pdf.yaml
    cat config-pdf.yaml >> tmp-config-pdf.yaml
    pdfcommand="pandoc -s -d tmp-config-pdf.yaml -o ./output/book-$nextbuild.pdf $buildcommand ./chapters/*.md"
    echo "    $pdfcommand"
    $pdfcommand
    rm ./tmp-config-pdf.yaml
fi

if [[ "$onlyRun" = "" || "$onlyRun" = "epub" ]]; then
    echo ""
    echo ">>> Generating ePub file"
    cat config-common.yaml > tmp-config-epub.yaml
    cat config-epub.yaml >> tmp-config-epub.yaml
    epubcommand="pandoc -s -d tmp-config-epub.yaml -o ./output/book-$nextbuild.epub $buildcommand ./chapters/*.md"
    echo "    $epubcommand"
    $epubcommand
    rm ./tmp-config-epub.yaml
fi

if [[ "$onlyRun" = "" || "$onlyRun" = "manuscript" ]]; then
    echo ""
    echo ">>> Generating manuscript file"
    
    cat config-common.yaml > tmp-config-manuscript.yaml
    cat config-manuscript.yaml >> tmp-config-manuscript.yaml

    manuscriptCommand="pandoc -s -d tmp-config-manuscript.yaml -o ./output/tmp-manuscript.md ./chapters/*.md"
    echo "    generating intermediary markdown:"
    echo "    $manuscriptCommand"
    $manuscriptCommand
    
    manuscriptCommand="pandoc -o ./output/manuscript-$nextbuild.docx --reference-doc template-manuscript.docx -f markdown -t docx ./output/tmp-manuscript.md"
    echo "    generating docx manuscript:"
    echo "    $manuscriptCommand"
    $manuscriptCommand

    rm ./tmp-config-manuscript.yaml
    rm ./output/tmp-manuscript.md
fi


if [[ "$bumpLevel" != "" && "$nextbuild" != "preview" ]]; then
    echo ""
    echo ">>> Tagging new build: git tag v$nextbuild"
    git tag "v$nextbuild"
    git push origin "v$nextbuild"
fi


echo ""
echo "All done!"
echo ""
