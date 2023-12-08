#!/usr/bin/env bash

d_own="$(realpath "$(dirname $0)")"
d_bin="$(realpath "$d_own/.bin")"
d_codec="$(realpath "$d_own/wx-codec")"
d_player="$(realpath "$d_own/wx-player")"

bash $d_player/build.sh "$d_bin"
# bash $d_codec/build.sh "$d_bin"