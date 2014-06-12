#!/bin/bash

name=$(osascript -e 'tell application "Spotify" to name of current track as string')
artist=$(osascript -e 'tell application "Spotify" to artist of current track as string')

echo "$name - $artist"

