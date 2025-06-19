# @EUGO_CHANGE - only build the Analysis subdirectory if EUGO_TRITON_BUILD_APPS is set
if (EUGO_TRITON_BUILD_APPS)
  add_subdirectory(Analysis)
endif()

add_subdirectory(Instrumentation)
