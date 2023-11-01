
function clean() {
	echo ">> Cleaning:"
	rm -rf ./bin
	rm -rf ./lib
	rm -rf ./build
	echo "<<"
}

function build() {
	echo ">> Building: $@"
	if [[ $# -ne 2 ]]; then
		echo "Argument count is incorrect. Expected: 2"
		return 1;
	fi
	if [[ "$1" != "wasm" && "$1" != "asm" ]]; then
		echo "Compilation backend is incorrect. Expected: asm | wasm"
		return 1;
	fi
	if [[ "$2" != "baseline" && "$2" != "h264" && "$2" != "h265" ]]; then
		echo "Compilation profile is incorrect. Expected: baseline | h264 | h265"
		return 1;
	fi
	clean;
	mkdir build
	cd build
	emcmake cmake .. -DCODEC_BACKEND="$1" -DCODEC_PROFILE="$2"
	# emmake make -j 4 VERBOSE=1
	emmake make -j 4
	# mv ../bin/prod.js ../bin/$2.$1.js
	echo "<<"
}

function help() {
printf "\
this is help
"
}

case $1 in
  build) { build "${@:2}"; };;
  clean) { clean;		   };;
  *) 	 { help;		   };;
esac