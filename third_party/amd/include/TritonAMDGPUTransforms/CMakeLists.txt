set(LLVM_TARGET_DEFINITIONS Passes.td)
mlir_tablegen(Passes.h.inc -gen-pass-decls -name TritonAMDGPU)
add_public_tablegen_target(TritonAMDGPUTransformsIncGen)
# @EUGO_CHANGE - no AMD support, but we don't comment anything out here as we don't `add_subdirectory` for `amd` in `CMakeLists.txt` in the root of the project.