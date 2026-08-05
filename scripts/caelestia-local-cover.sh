#!/usr/bin/env bash
# Find a tagged local track by artist/title and expose its embedded cover.
set -euo pipefail

music_dir=/mnt/windows/Users/Kaan/Music
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/caelestia/local-covers"
artist=${1:-}
title=${2:-}

[[ -d "$music_dir" && -n "$title" ]] || exit 0
mkdir -p "$cache_dir"

normalise() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]'
}

wanted_artist=$(normalise "$artist")
wanted_title=$(normalise "$title")
key=$(printf '%s\0%s' "$wanted_artist" "$wanted_title" | sha256sum | cut -d' ' -f1)
cover="$cache_dir/$key.jpg"

if [[ -s "$cover" ]]; then
  printf 'file://%s\n' "$cover"
  exit 0
fi

while IFS= read -r -d '' file; do
  tags=$(ffprobe -v error -show_entries format_tags=artist,title \
    -of default=noprint_wrappers=1 "$file" 2>/dev/null || true)
  file_artist=$(sed -n 's/^TAG:artist=//Ip' <<<"$tags" | head -n1)
  file_title=$(sed -n 's/^TAG:title=//Ip' <<<"$tags" | head -n1)

  [[ $(normalise "$file_title") == "$wanted_title" ]] || continue
  # Some Spotify local tracks expose multiple artists differently. A title
  # match is sufficient when either artist string contains the other.
  normal_artist=$(normalise "$file_artist")
  if [[ -n "$wanted_artist" && -n "$normal_artist" &&
        "$wanted_artist" != *"$normal_artist"* &&
        "$normal_artist" != *"$wanted_artist"* ]]; then
    continue
  fi

  tmp="$cover.tmp.jpg"
  if ffmpeg -loglevel error -y -i "$file" -map 0:v:0 -frames:v 1 "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
    mv "$tmp" "$cover"
    printf 'file://%s\n' "$cover"
    exit 0
  fi
  rm -f "$tmp"
done < <(find "$music_dir" -type f \( -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.flac' -o -iname '*.ogg' \) -print0)

