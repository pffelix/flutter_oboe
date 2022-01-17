cmake_minimum_required(VERSION 3.4.1)

project (flutter_oboe)
set(CMAKE_BUILD_TYPE Release)

# Set the path to the Oboe directory
set (OBOE_DIR ../../oboe)

# Add the Oboe library as a subdirectory in your project
add_subdirectory (${OBOE_DIR} ./oboe)

# Specify the path to the Oboe header files
include_directories (${OBOE_DIR}/include)

file(GLOB_RECURSE SOURCES
     "src/main/cpp/*.h"
     "src/main/cpp/*.c"
     "src/main/cpp/*.cpp"
)

add_library(flutter_oboe
        SHARED
        ${SOURCES}
)

target_link_libraries(flutter_oboe oboe)