#!/usr/bin/env bash

set -x

# build index.js
parcel build src/index.js --no-source-maps --target browser
mv dist/* ./example

# build codec
cd lib/codec
bash build.sh
mv combine/prod.* ../../example