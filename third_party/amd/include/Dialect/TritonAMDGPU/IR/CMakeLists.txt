# set(MLIR_BINARY_DIR ${CMAKE_BINARY_DIR})

# set(LLVM_TARGET_DEFINITIONS TritonAMDGPUOps.td)
# mlir_tablegen(Dialect.h.inc -gen-dialect-decls -dialect=amdgpu)
# mlir_tablegen(Dialect.cpp.inc -gen-dialect-defs -dialect=amdgpu)
# mlir_tablegen(OpsConversions.inc -gen-llvmir-conversions)
# mlir_tablegen(Ops.h.inc -gen-op-decls)
# mlir_tablegen(Ops.cpp.inc -gen-op-defs)
# add_mlir_doc(TritonAMDGPUDialect TritonAMDGPUDialect dialects/ -gen-dialect-doc)
# add_mlir_doc(TritonAMDGPUOps TritonAMDGPUOps dialects/ -gen-op-doc)
# add_public_tablegen_target(TritonAMDGPUTableGen)

# set(LLVM_TARGET_DEFINITIONS TritonAMDGPUAttrDefs.td)
# mlir_tablegen(TritonAMDGPUEnums.h.inc -gen-enum-decls)
# mlir_tablegen(TritonAMDGPUEnums.cpp.inc -gen-enum-defs)
# mlir_tablegen(TritonAMDGPUAttrDefs.h.inc -gen-attrdef-decls)
# mlir_tablegen(TritonAMDGPUAttrDefs.cpp.inc -gen-attrdef-defs)
# add_public_tablegen_target(TritonAMDGPUAttrDefsIncGen)
# @EUGO_CHANGE - no AMD support