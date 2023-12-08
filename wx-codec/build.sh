#!/bin/bash
set -e

own_d=$(realpath $(dirname $0))
mid_d=$(realpath $own_d/.mid); [ -d $mid_d ] || mkdir $mid_d
out_d=$(realpath $own_d/.out); [ -d $out_d ] || mkdir $out_d

profiles_support=("base" "h264" "h265")
backends_support=("wasm" "jasm")

function __build_variant() {
  local profile=$1
  local backend=$2
  local rebuild=$3
  echo
  echo "[Profile=$profile, Backend=$backend, Rebuild=$rebuild]"

  local var_mid_d=$(realpath $mid_d/$profile.$backend)
  [ -d $var_mid_d ] || mkdir $var_mid_d

  pushd $var_mid_d > /dev/null
    emcmake cmake $own_d -Wno-dev \
      -DLIBCODEC_PROFILE=$profile \
      -DLIBCODEC_BACKEND=$backend \
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=$out_d
    if [ $rebuild = true ]; then
      emmake make clean
    fi
    emmake make -j 16
  popd > /dev/null
  # node ../tool/wrapper.js "$out_d" "$pval.$bval"
}

profiles=()
rebuild=false
for arg in $@; do
  argexp="\<$arg\>"
  if [[ ${profiles_support[@]} =~ $argexp ]]; then
    [[ ! ${profiles[@]} =~ $argexp ]] && profiles+=("$arg")
  elif [ $arg == "--rebuild" ]; then
    rebuild=true
  else
    echo "unsupported argument: $arg"
    exit 1
  fi
done

profiles=${profiles[@]:-${profiles_support[@]}}
for profile in ${profiles[@]}; do
  for backend in ${backends_support[@]}; do
    __build_variant $profile $backend $rebuild
  done
done