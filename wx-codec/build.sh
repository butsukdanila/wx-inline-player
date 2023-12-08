#!/bin/bash

d_src="$(dirname $0)"

d_mid="$(realpath "$d_src/.mid")"
rm -rf "$d_mid"

d_out="$(realpath "$d_src/.out")"
rm -rf "$d_out"

profiles=("base" "h264" "h265")
backends=("wasm" "jasm")

function __validate_args() {
  local IFS="|"
  local pval=$1
  local preg="\<${1}\>"
  if [[ ! ${profiles[@]} =~ $preg ]]; then
    echo "invalid codec profile: $pval. available: ${profiles[*]}"
    return 1;
  fi
  local bval=$2
  local breg="\<${2}\>"
  if [[ ! ${backends[@]} =~ $breg ]]; then
    echo "invalid codec backend: $bval. available: ${backends[*]}"
    return 1;
  fi
  return 0;
}

function __build_variant() {
  if !(__validate_args "${@}"); then
    return 1;
  fi
  local pval=$1
  local bval=$2
  emcmake cmake .. -Wno-dev \
    -Dlibcodec-profile="$pval" \
    -Dlibcodec-backend="$bval" \
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$d_out"
  emmake make -j 8
  # node ../tool/wrapper.js "$d_out" "$pval.$bval"
}

mkdir "$d_mid"
cd "$d_mid"

if [ $# -eq 0 ]; then
  for pval in "${profiles[@]}"; do
    for bval in "${backends[@]}"; do
      __build_variant "$pval" "$bval"
    done
  done
elif [ $# -eq 1 ]; then
  pval=$1
  if [[ ${profiles[@]} =~ $pval ]]; then
    for bval in "${backends[@]}"; do
      __build_variant "$pval" "$bval"
    done
  else
    echo "invalid codec profile: $pval. available: ${profiles[*]}"
    return 1
  fi
elif [ $# -eq 2 ]; then
  pval=$1
  bval=$2
  __build_variant "$pval" "$bval"
else
  echo "unsupported number of arguments"
  return 1
fi