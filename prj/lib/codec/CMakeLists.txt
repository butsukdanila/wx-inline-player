cmake_minimum_required(VERSION 3.2)
project(player-codec)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/arc)
set(CMAKE_CXX_STANDARD 11)

if (NOT DEFINED CODEC_PROFILE)
  message(WARNING "Codec profile wasn't specified. Using default: base")
  set(CODEC_PROFILE "base")
endif()

if (NOT DEFINED CODEC_BACKEND)
  message(WARNING "Codec backend wasn't specified. Using default: wasm")
  set(CODEC_BACKEND "wasm")
endif()

add_executable(${PROJECT_NAME} src/main.cpp)

include_directories(3rdparty/)
add_subdirectory(3rdparty/tinyh264)
target_link_libraries(${PROJECT_NAME} tinyh264)

include_directories(src/)
add_subdirectory(src/stream)
add_subdirectory(src/factor)
add_subdirectory(src/demuxer)
add_subdirectory(src/codec)
target_link_libraries(${PROJECT_NAME} stream factor demuxer codec)

if (${CODEC_PROFILE} STREQUAL "h264")
  message(FATAL_ERROR "h264 UNSUPPORTED")
  # todo compile from source
  # link_directories(3rdparty/openh264)
  # link_libraries(openh264wasm)
  # add_compile_definitions(USE_OPEN_H264)
elseif (${CODEC_PROFILE} STREQUAL "h265")
  set(DISABLE_SSE ON)
  add_subdirectory(3rdparty/de265)
  add_compile_definitions(USE_OPEN_H265)
  target_link_libraries(${PROJECT_NAME} libde265)
endif()

set(EM_COMMON_PARAM "\
  -O3 \
  -s ENVIRONMENT=\"web,worker\" \
  -s SINGLE_FILE=1 \
  -s FETCH=0 \
  -s DISABLE_EXCEPTION_CATCHING=0 \
  -s ERROR_ON_UNDEFINED_SYMBOLS=0 \
  -s NO_EXIT_RUNTIME=0 \
  -s FILESYSTEM=0 \
  -s INVOKE_RUN=0 \
  -s ASSERTIONS=1 \
  -s TOTAL_MEMORY=16777216 \
  -s ALLOW_MEMORY_GROWTH=1 \
  -s EXPORTED_FUNCTIONS=\"['_codecInit', '_codecSetBridgeName', '_codecDecode', '_codecSetVideoBuffer', '_codecSetAudioBuffer', '_codecTry2Seek', '_codecFree']\" \
")

if (${CODEC_BACKEND} STREQUAL "wasm")
  set(EM_PARAM_BACKEND "-s WASM=1")
elseif(${CODEC_BACKEND} STREQUAL "asm")
  set(EM_PARAM_BACKEND "-s WASM=0 -s LEGACY_VM_SUPPORT=1 -s MEM_INIT_METHOD=0 -s ELIMINATE_DUPLICATE_FUNCTIONS=1")
endif()

set(EM_OPTIMIZE_PARAM "\
  --closure 1 \
  --memory-init-file 0 \
  --llvm-lto 3 \
")

set_target_properties(${PROJECT_NAME} 
  PROPERTIES 
    LINK_FLAGS "${EM_COMMON_PARAM} ${EM_PARAM_BACKEND} ${EM_OPTIMIZE_PARAM}"
)