# @EUGO_CHANGE
install(
  TARGETS triton proton LIBRARY
  DESTINATION ${SKBUILD_PLATLIB_DIR}/triton/_C
)

install(
  TARGETS GPUInstrumentationTestLib LIBRARY
  DESTINATION ${SKBUILD_PLATLIB_DIR}/triton/instrumentation
)

# IMPORTANT: after updating to new version, we will unlikely have to manually add files missing in our older commit due to .gitignore mess introduced by triton team, as these paths are covered by this function call.
# IMPORTANT: we need to exclude them twice. First when copying python/triton (because they are nested here), and second in `pyproject.toml` when they are copied together with library targets.
install(
  DIRECTORY "python/triton/"
  DESTINATION ${SKBUILD_PLATLIB_DIR}/triton
  FILES_MATCHING
    PATTERN "*.py"
    PATTERN "_C/include" EXCLUDE # TODO+ do we really need these? Because we only copy `PATTERN "*.py"` we shouldn't need, but check further.
    PATTERN "_C/include/*" EXCLUDE # TODO+ do we really need these? Because we only copy `PATTERN "*.py"` we shouldn't need, but check further.
)

install(
  DIRECTORY "third_party/nvidia/backend/"
  DESTINATION ${SKBUILD_PLATLIB_DIR}/triton/backends/nvidia
  FILES_MATCHING
    PATTERN "*.py"
    PATTERN "*.c"
)

install(
  FILES "third_party/nvidia/backend/lib/libdevice.10.bc"
  DESTINATION ${SKBUILD_PLATLIB_DIR}/triton/backends/nvidia/lib
)

install(
  DIRECTORY "third_party/nvidia/language/cuda/"
  DESTINATION ${SKBUILD_PLATLIB_DIR}/triton/language/extra/cuda
  FILES_MATCHING
    PATTERN "*.py"
)

install(
  DIRECTORY "third_party/proton/proton/"
  DESTINATION ${SKBUILD_PLATLIB_DIR}/triton/profiler
  FILES_MATCHING
    PATTERN "*.py"
    # PATTERN "context.py" EXCLUDE  # they exclude in their latest version, but it's probably incorrect
)

install(
  DIRECTORY "third_party/nvidia/tools/cuda/"
  DESTINATION ${SKBUILD_PLATLIB_DIR}/triton/tools
  FILES_MATCHING
    PATTERN "*.c"
    PATTERN "*.h"
)