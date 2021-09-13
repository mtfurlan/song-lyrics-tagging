#!/bin/bash
set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

tmpDir=/tmp/lyricsTmp

underline () {
    echo -e "\e[4m${1}\e[0m"
}

# shellcheck disable=SC2120
help () {
    # if arguments, print them
    [ $# == 0 ] || echo "$*"

    #TODO
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [$(underline options)] $(underline song)
    song: path to mp3 or flac or whatever that does tags
Available options:
    -h, --help       display this help and exit
EOF

    # if args, exit 1 else exit 0
    [ $# == 0 ] || exit 1
    exit 0
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}

# getopt short options go together, long options have commas
TEMP=$(getopt -o h --long help -n "$0" -- "$@")
#shellcheck disable=SC2181
if [ $? != 0 ] ; then
    die "something wrong with getopt"
fi
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h|--help) help; exit 0; shift ;;
        --) shift ; break ;;
        *) die "issue parsing args, unexpected argument '$0'!" ;;
    esac
done

songPath=${1:-}
if [[ -z "$songPath" ]]; then
    help "no song passed in"
fi

msg "processiung '$songPath'"
songFilename=$(basename -- "$songPath")
songExtension="${songFilename##*.}"


#exiftool -artist -album -title -lyrics -lyrics-xxx "$songPath"
artist=$(exiftool -s -s -s -artist "$songPath")
title=$(exiftool -s -s -s -title "$songPath")
lyrics=$(exiftool -s -s -s -lyrics "$songPath")
lyricsXXX=$(exiftool -s -s -s -lyrics-xxx "$songPath")
lyricsWeb=$("$DIR/getLyrics.py" "$artist" "$title")

mkdir -p $tmpDir
echo "$artist - $title" > $tmpDir/info
echo "$lyrics" > $tmpDir/lyrics
echo "$lyricsXXX" > $tmpDir/lyricsXXX
echo "$lyricsWeb" > $tmpDir/lyricsWeb

# open vim like
# ┌──────────────────────────────────┐
# │ info                             │
# ├────────┬────────────┬────────────┤
# │ lyrics │ lyrics-xxx │ web-lyrics │
# └────────┴────────────┴────────────┘
vim -o2 -O $tmpDir/info $tmpDir/lyrics* -c "wincmd K" -c "resize 1"

lyricsChoice=$(sind -o lyrics lyricsXXX lyricsWeb)
echo "chose $lyricsChoice"

tmpFile="tmpOutputSong.$songExtension"
ffmpeg -i "$songPath" -y -acodec copy -metadata lyrics-XXX= "$tmpFile"
mv "$tmpFile" "$songPath"
ffmpeg -i "$songPath" -y -acodec copy -metadata lyrics="$(cat "$tmpDir/$lyricsChoice")" "$tmpFile"
mv "$tmpFile" "$songPath"
#echo -e "$artist - $title:\nlyrics: $lyrics\n\nlyrics-xxx: $lyricsXXX\n\nlyricsWeb: $lyricsWeb"

# show all tags:
#exiftool -a -s 03\ -\ Roll\ the\ Bones.mp3
#ffmpeg -i '03 - Roll the Bones.mp3' -f ffmetadata - 2>/dev/null
#write/delete a tag
#ffmpeg -i '03 - Roll the Bones.mp3' -y -acodec copy -metadata lyrics-XXX= 'output.mp3'


