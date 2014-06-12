#!/bin/bash

if ps aux | grep "spotify" > /dev/null
then
	name=$(osascript -e 'tell application "Spotify" to name of current track as string')
	artist=$(osascript -e 'tell application "Spotify" to artist of current track as string')
	
	echo "$name - $artist"
fi
