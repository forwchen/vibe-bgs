######################################################################
## Find OpenCV - variables set:
##  OpenCV_FOUND
##  OpenCV_LIBRARIES
##  OpenCV_INCLUDE_DIRS
##
## This script is a combination from multiple sources that use
## different variable names; the names are reconciled at the end
## of the script.

###########################################################
#                  Find OpenCV Library
# See http://sourceforge.net/projects/opencvlibrary/
#----------------------------------------------------------
#
## 1: Setup:
# The following variables are optionally searched for defaults
#  OpenCV_DIR:            Base directory of OpenCv tree to use.
#
## 2: Variable
# The following are set after configuration is done: 
#  
#  OpenCV_FOUND
#  OpenCV_LIBS
#  OpenCV_INCLUDE_DIR
#  OpenCV_VERSION (OpenCV_VERSION_MAJOR, OpenCV_VERSION_MINOR, OpenCV_VERSION_PATCH)
#
#
# Deprecated variable are used to maintain backward compatibility with
# the script of Jan Woetzel (2006/09): www.mip.informatik.uni-kiel.de/~jw
#  OpenCV_INCLUDE_DIRS
#  OpenCV_LIBRARIES
#  OpenCV_LINK_DIRECTORIES
# 
## 3: Version
#
# 2010/04/07 Benoit Rat, Correct a bug when OpenCVConfig.cmake is not found.
# 2010/03/24 Benoit Rat, Add compatibility for when OpenCVConfig.cmake is not found.
# 2010/03/22 Benoit Rat, Creation of the script.
#
#
# tested with:
# - OpenCV 2.1:  MinGW, MSVC2008
# - OpenCV 2.0:  MinGW, MSVC2008, GCC4
#
#
## 4: Licence:
#
# Copyright: 2009 Benoit Rat
# CopyPolicy: LGPLv2.1
# 
#----------------------------------------------------------

# Lorenzo Natale -- Feb 2011
# Improve compatibility with OpenCV package in Ubuntu 10.10
# Lorenzo Natale -- March 2011
# Removing OpenCV_INCLUDE_DIRS from required arguments
# Since not all version of OpenCV set OpenCV_INCLUDE_DIRS. Problem detected with OpenCV 2.0 OpenCVConfig.cmake 
# directly calls INCLUDE_DIRECTORIES() and does not propagate any OpenCV_INCLUDE_ variable

# let's skip module mode, and see if a OpenCVConfig.cmake file is around
# this searches in system directories and ${OpenCV_DIR}
set(OpenCV_DIR "/home/forwchen/opencv2/share/OpenCV")
find_package(OpenCV QUIET NO_MODULE)
if (OpenCV_FOUND)
  set(OpenCV_CONFIG_MODE true)
  
  ## OpenCVConfig.cmake sets OpenCV_LIBS OpenCV_INCLUDE_DIRS
  ## but we need OpenCV_LIBRARIES
  set(OpenCV_LIBRARIES ${OpenCV_LIBS})
endif()

### If the above failed continues with traditional search method
## To keep backward compatibility we keep the whole script
## intact, however there is probably a lot of redundancy now
if (NOT OpenCV_CONFIG_MODE)
  find_path(OpenCV_DIR "OpenCVConfig.cmake" DOC "Root directory of OpenCV")

##====================================================
## Find OpenCV libraries
##----------------------------------------------------
if(EXISTS "${OpenCV_DIR}")

        #When its possible to use the Config script use it.
        if(EXISTS "${OpenCV_DIR}/OpenCVConfig.cmake")

                ## Include the standard CMake script
                include("${OpenCV_DIR}/OpenCVConfig.cmake")

                ## Search for a specific version
                set(CVLIB_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")

        #Otherwise it try to guess it.
        else(EXISTS "${OpenCV_DIR}/OpenCVConfig.cmake")

                set(OPENCV_LIB_COMPONENTS cxcore cv ml highgui cvaux)
                find_path(OpenCV_INCLUDE_DIR "cv.h" PATHS "${OpenCV_DIR}" PATH_SUFFIXES "include" "include/opencv" DOC "")
                if(EXISTS  ${OpenCV_INCLUDE_DIR})
                    include_directories(${OpenCV_INCLUDE_DIR})
                endif(EXISTS  ${OpenCV_INCLUDE_DIR})

                #Find OpenCV version by looking at cvver.h
                file(STRINGS ${OpenCV_INCLUDE_DIR}/cvver.h OpenCV_VERSIONS_TMP REGEX "^#define CV_[A-Z]+_VERSION[ \t]+[0-9]+$")
                string(REGEX REPLACE ".*#define CV_MAJOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MAJOR ${OpenCV_VERSIONS_TMP})
                string(REGEX REPLACE ".*#define CV_MINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MINOR ${OpenCV_VERSIONS_TMP})
                string(REGEX REPLACE ".*#define CV_SUBMINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_PATCH ${OpenCV_VERSIONS_TMP})
                set(OpenCV_VERSION ${OpenCV_VERSION_MAJOR}.${OpenCV_VERSION_MINOR}.${OpenCV_VERSION_PATCH} CACHE STRING "" FORCE)
                set(CVLIB_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")
                
        endif(EXISTS "${OpenCV_DIR}/OpenCVConfig.cmake")

        
        

        ## Initiate the variable before the loop
        set(OpenCV_LIBS "")
        set(OpenCV_FOUND_TMP true)

        ## Loop over each components
        foreach(__CVLIB ${OPENCV_LIB_COMPONENTS})

                find_library(OpenCV_${__CVLIB}_LIBRARY_DEBUG NAMES "${__CVLIB}${CVLIB_SUFFIX}d" "lib${__CVLIB}${CVLIB_SUFFIX}d" PATHS "${OpenCV_DIR}/lib" NO_DEFAULT_PATH)
                find_library(OpenCV_${__CVLIB}_LIBRARY_RELEASE NAMES "${__CVLIB}${CVLIB_SUFFIX}" "lib${__CVLIB}${CVLIB_SUFFIX}" PATHS "${OpenCV_DIR}/lib" NO_DEFAULT_PATH)
                
                #Remove the cache value
                set(OpenCV_${__CVLIB}_LIBRARY "" CACHE STRING "" FORCE)
        
                #both debug/release
                if(OpenCV_${__CVLIB}_LIBRARY_DEBUG AND OpenCV_${__CVLIB}_LIBRARY_RELEASE)
                        set(OpenCV_${__CVLIB}_LIBRARY debug ${OpenCV_${__CVLIB}_LIBRARY_DEBUG} optimized ${OpenCV_${__CVLIB}_LIBRARY_RELEASE}  CACHE STRING "" FORCE)
                #only debug
                elseif(OpenCV_${__CVLIB}_LIBRARY_DEBUG)
                        set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_DEBUG}  CACHE STRING "" FORCE)
                #only release
                elseif(OpenCV_${__CVLIB}_LIBRARY_RELEASE)
                        set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_RELEASE}  CACHE STRING "" FORCE)
                #no library found
                else()
                        set(OpenCV_FOUND_TMP false)
                endif()
                
                #Add to the general list
                if(OpenCV_${__CVLIB}_LIBRARY)
                        set(OpenCV_LIBS ${OpenCV_LIBS} ${OpenCV_${__CVLIB}_LIBRARY})
                endif(OpenCV_${__CVLIB}_LIBRARY)
                
        endforeach(__CVLIB)


        set(OpenCV_FOUND ${OpenCV_FOUND_TMP} CACHE BOOL "" FORCE)


else(EXISTS "${OpenCV_DIR}")
        set(ERR_MSG "Please specify OpenCV directory using OpenCV_DIR env. variable")
endif(EXISTS "${OpenCV_DIR}")


##====================================================
## Print message
##----------------------------------------------------
if(NOT OpenCV_FOUND)
  # make FIND_PACKAGE friendly
  if(NOT OpenCV_FIND_QUIETLY)
        if(OpenCV_FIND_REQUIRED)
          message(FATAL_ERROR "OpenCV required but some headers or libs not found. ${ERR_MSG}")
        else(OpenCV_FIND_REQUIRED)
          message(STATUS "WARNING: OpenCV was not found. ${ERR_MSG}")
        endif(OpenCV_FIND_REQUIRED)
  endif(NOT OpenCV_FIND_QUIETLY)
endif(NOT OpenCV_FOUND)
##====================================================


##====================================================
## Backward compatibility
##----------------------------------------------------
if(OpenCV_FOUND)
option(OpenCV_BACKWARD_COMPA "Add some variable to make this script compatible with the other version of FindOpenCV.cmake" false)
if(OpenCV_BACKWARD_COMPA)
        find_path(OpenCV_INCLUDE_DIRS "cv.h" PATHS "${OpenCV_DIR}" PATH_SUFFIXES "include" "include/opencv" DOC "Include directory") 
        find_path(OpenCV_INCLUDE_DIR "cv.h" PATHS "${OpenCV_DIR}" PATH_SUFFIXES "include" "include/opencv" DOC "Include directory")
        set(OpenCV_LIBRARIES "${OpenCV_LIBS}" CACHE STRING "" FORCE)
endif(OpenCV_BACKWARD_COMPA)
endif(OpenCV_FOUND)
##====================================================

SET(OpenCV_LIBRARIES ${OpenCV_LIBS})
SET(OpenCV_INCLUDE_DIRS ${OpenCV_INCLUDE_DIR})
# support old variable names
SET(OPENCV_LIBRARIES ${OpenCV_LIBS})
SET(OPENCV_INCLUDE_DIR ${OpenCV_INCLUDE_DIR})

endif(NOT OpenCV_CONFIG_MODE)

INCLUDE(FindPackageHandleStandardArgs)
# Not all version of OpenCV set OpenCV_INCLUDE_DIRS, removing it from required arguments
# Lorenzo Natale March 2011. See notes on top of file.
# FIND_PACKAGE_HANDLE_STANDARD_ARGS(OpenCV "OpenCV not found" OpenCV_LIBRARIES OpenCV_INCLUDE_DIRS)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OpenCV "OpenCV not found" OpenCV_LIBRARIES)
