cmake_minimum_required(VERSION 2.8)
PROJECT(main)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules ${CMAKE_MODULE_PATH})

Find_package(OpenCV 2.0 REQUIRED)
Find_package(Boost)
set(OPT_CXX_FLAGS "-O3 -fopenmp -funroll-loops -march=native -mtune=native --fast-math -mfpmath=sse -msse3 ")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x -Wall -DNDEBUG ${OPT_CXX_FLAGS}")

FILE(GLOB SRC "*.h" "*.cpp")

add_executable(${PROJECT_NAME} ${SRC})
include_directories(
	${OpenCV_INCLUDE_DIRS}
	"/home/forwchen/lib/include"
)

link_directories(
	"/home/forwchen/lib/lib"
)

target_link_libraries( ${PROJECT_NAME}  
	${OpenCV_LIBRARIES}
	boost_filesystem
	boost_system
	boost_thread

)


