#!/usr/bin/env snakespawn
#| pip: lyricsgenius
from lyricsgenius import Genius
import argparse
import re


# file just contains key, nothing else
file = open("lyricsgenius.secret")
secret = file.read().replace("\n","")
file.close()
genius = Genius(secret)

# Turn off status messages
genius.verbose = False

# do we remove section headers (e.g. [Chorus]) from lyrics when searching
genius.remove_section_headers = False
#genius.response_format = 'plain'

parser = argparse.ArgumentParser(description='get lyrics for song')
parser.add_argument('artist', type=str, help='artist')
parser.add_argument('title', type=str, help='title')

args = parser.parse_args()

song = genius.search_song(args.title, args.artist)

#print(song.lyrics)
lyrics = song.lyrics
#handle "$title Lyrics" prepended to the first line or as the first line
lyrics = re.sub(r".*" + re.escape(song.title) + r" Lyrics\r?\n?", '', lyrics)

# handle embed shit on the last line
lyricsArr=lyrics.split("\n");
if "embed" in lyricsArr[-1].lower():
    lyricsArr=lyricsArr[:-1]
lyrics = "\n".join(lyricsArr)

print(lyrics)
#print(re.sub(r'EmbedShare URLCopyEmbedCopy$', '', song.lyrics))
