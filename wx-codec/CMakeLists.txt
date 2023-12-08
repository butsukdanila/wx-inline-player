cmake_minimum_required(VERSION 3.2)
project(libcodec)

set(CMAKE_CXX_STANDARD 11)

if (NOT DEFINED LIBCODEC_PROFILE)
  message(FATAL_ERROR "Codec profile wasn't specified")
endif()

if (NOT DEFINED LIBCODEC_BACKEND)
  message(FATAL_ERROR "Codec backend wasn't specified")
endif()

set(LIBCODEC "${LIBCODEC_PROFILE}.${LIBCODEC_BACKEND}")

add_executable(${LIBCODEC} src/main.cpp)

include_directories(3rdparty/)
add_subdirectory(3rdparty/tinyh264)
target_link_libraries(${LIBCODEC} tinyh264)

if (${LIBCODEC_PROFILE} STREQUAL "h264")
  add_custom_target(project-openh264
    COMMAND $(MAKE) OS=linux ARCH=x86 V=1
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/3rdparty/openh264
  )
  add_dependencies(${LIBCODEC} project-openh264)
  target_link_directories(${LIBCODEC} PUBLIC 3rdparty/openh264)
  target_link_libraries(${LIBCODEC} openh264)
  add_compile_definitions(USE_OPEN_H264)
elseif (${LIBCODEC_PROFILE} STREQUAL "h265")
  set(DISABLE_SSE ON)
  add_subdirectory(3rdparty/de265)
  target_link_libraries(${LIBCODEC} de265)
  add_compile_definitions(USE_OPEN_H265)
endif()

include_directories(src/)
add_subdirectory(src/stream)
add_subdirectory(src/factor)
add_subdirectory(src/demuxer)
add_subdirectory(src/codec)
target_link_libraries(${LIBCODEC} stream factor demuxer codec)

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

if (${LIBCODEC_BACKEND} STREQUAL "wasm")
  set(EM_PARAM_BACKEND "-sWASM=1")
elseif(${LIBCODEC_BACKEND} STREQUAL "asm")
  set(EM_PARAM_BACKEND "-sWASM=0 -sLEGACY_VM_SUPPORT=1")
endif()

set(EM_OPTIMIZE_PARAM "\
  --closure 1 \
  --memory-init-file 0 \
")

set_target_properties(${LIBCODEC} 
  PROPERTIES 
    LINK_FLAGS "${EM_COMMON_PARAM} ${EM_PARAM_BACKEND} ${EM_OPTIMIZE_PARAM}"
)