# @EUGO_CHANGE: @begin only build Analysis + Dialect when EUGO_TRITON_BUILD_APPS is set.
# Both build test-only static libraries (TritonTestAnalysis, TritonTestDialect) that aren't
# shipped in our wheel. Instrumentation/ and Proton/ stay unconditional: the former produces
# libGPUInstrumentationTestLib.so which IS shipped in the wheel (per __info.md bullet 7), and
# the latter (TritonTestProton) was already built unconditionally in pre-merge HEAD.
if (EUGO_TRITON_BUILD_APPS)
  add_subdirectory(Analysis)
  add_subdirectory(Dialect)
endif()
# @EUGO_CHANGE: @end
add_subdirectory(Instrumentation)
add_subdirectory(Proton)
