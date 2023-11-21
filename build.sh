#!/usr/bin/env bash

set -x

d_own="$(dirname $0)"
d_bin="$(realpath "$d_own/.bin")"
d_src="$(realpath "$d_own/src")"
d_lib="$(realpath "$d_own/lib/codec")"

rm -rf "$d_bin"
mkdir "$d_bin"

# build index
npm install
npx parcel build $d_src/index.js --no-source-maps --dist-dir $d_bin

# build codec
bash $d_lib/build.sh
mv $d_lib/.out/*.prod.js $d_bin