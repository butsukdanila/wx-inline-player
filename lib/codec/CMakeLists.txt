cmake_minimum_required(VERSION 3.2)
project(player-codec)

set(CMAKE_CXX_STANDARD 11)

if (NOT DEFINED CODEC_NAME)
  message(WARNING "CODEC_NAME wasn't specified. Using default: libcodec")
  set(CODEC_NAME "libcodec")
endif()

if (NOT DEFINED CODEC_PROFILE)
  message(WARNING "Codec profile wasn't specified. Using default: base")
  set(CODEC_PROFILE "base")
endif()

if (NOT DEFINED CODEC_BACKEND)
  message(WARNING "Codec backend wasn't specified. Using default: wasm")
  set(CODEC_BACKEND "wasm")
endif()

add_executable(${CODEC_NAME} src/main.cpp)

include_directories(3rdparty/)
add_subdirectory(3rdparty/tinyh264)
target_link_libraries(${CODEC_NAME} tinyh264)

if (${CODEC_PROFILE} STREQUAL "h264")
  add_custom_target(project-openh264
    COMMAND $(MAKE) OS=linux ARCH=x86 V=1
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/3rdparty/openh264
  )
  add_dependencies(${CODEC_NAME} project-openh264)
  target_link_directories(${CODEC_NAME} PUBLIC 3rdparty/openh264)
  target_link_libraries(${CODEC_NAME} openh264)
  add_compile_definitions(USE_OPEN_H264)
elseif (${CODEC_PROFILE} STREQUAL "h265")
  set(DISABLE_SSE ON)
  add_subdirectory(3rdparty/de265)
  target_link_libraries(${CODEC_NAME} de265)
  add_compile_definitions(USE_OPEN_H265)
endif()

include_directories(src/)
add_subdirectory(src/stream)
add_subdirectory(src/factor)
add_subdirectory(src/demuxer)
add_subdirectory(src/codec)
target_link_libraries(${CODEC_NAME} stream factor demuxer codec)

set(EM_COMMON_PARAM "\
  -O3 \
  -sASSERTIONS=1 \
  -sINVOKE_RUN=0 \
  -sEXIT_RUNTIME=1 \
  -sINITIAL_MEMORY=16777216 \
  -sALLOW_MEMORY_GROWTH=1 \
  -sENVIRONMENT=\"web,worker\" \
  -sDISABLE_EXCEPTION_CATCHING=0 \
  -sFILESYSTEM=0 \
  -sEXPORTED_FUNCTIONS=@${PROJECT_SOURCE_DIR}/src/main.exp \
  -sERROR_ON_UNDEFINED_SYMBOLS=0 \
  -sFETCH=0 \
  -sSINGLE_FILE=1 \
")

if (${CODEC_BACKEND} STREQUAL "wasm")
  set(EM_PARAM_BACKEND "-sWASM=1")
elseif(${CODEC_BACKEND} STREQUAL "asm")
  set(EM_PARAM_BACKEND "-sWASM=0 -sLEGACY_VM_SUPPORT=1")
endif()

set(EM_OPTIMIZE_PARAM "\
  --closure 1 \
  --memory-init-file 0 \
")

set_target_properties(${CODEC_NAME} 
  PROPERTIES 
    LINK_FLAGS "${EM_COMMON_PARAM} ${EM_PARAM_BACKEND} ${EM_OPTIMIZE_PARAM}"
)