#!/usr/bin/env python3
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

# Remove section headers (e.g. [Chorus]) from lyrics when searching
genius.remove_section_headers = True

parser = argparse.ArgumentParser(description='get lyrics for song')
parser.add_argument('artist', type=str, help='artist')
parser.add_argument('title', type=str, help='title')

args = parser.parse_args()

song = genius.search_song(args.title, args.artist)

#song = genius.search_song("Ecstasy", "Wax Tailor")
#print(song)
print(re.sub(r'EmbedShare URLCopyEmbedCopy$', '', song.lyrics))
