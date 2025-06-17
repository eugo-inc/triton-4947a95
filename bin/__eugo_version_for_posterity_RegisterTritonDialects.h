#pragma once
// #include "amd/include/Dialect/TritonAMDGPU/IR/Dialect.h" @EUGO_CHANGE - no AMD support
// #include "amd/include/TritonAMDGPUTransforms/Passes.h" @EUGO_CHANGE - no AMD support
#include "third_party/nvidia/include/Dialect/NVGPU/IR/Dialect.h"
#include "third_party/nvidia/include/Dialect/NVWS/IR/Dialect.h"
#include "third_party/proton/dialect/include/Dialect/Proton/IR/Dialect.h"
#include "triton/Dialect/Triton/IR/Dialect.h"
#include "triton/Dialect/TritonGPU/IR/Dialect.h"
#include "triton/Dialect/TritonNvidiaGPU/IR/Dialect.h"

// Below headers will allow registration to ROCm passes
// #include "TritonAMDGPUToLLVM/Passes.h" @EUGO_CHANGE - no AMD support
// #include "TritonAMDGPUTransforms/Passes.h" @EUGO_CHANGE - no AMD support
// #include "TritonAMDGPUTransforms/TritonGPUConversion.h" @EUGO_CHANGE - no AMD support

#include "triton/Dialect/Triton/Transforms/Passes.h"
#include "triton/Dialect/TritonGPU/Transforms/Passes.h"
#include "triton/Dialect/TritonNvidiaGPU/Transforms/Passes.h"

#include "nvidia/hopper/include/Transforms/Passes.h"
#include "nvidia/include/Dialect/NVWS/Transforms/Passes.h"
#include "nvidia/include/NVGPUToLLVM/Passes.h"
#include "nvidia/include/TritonNVIDIAGPUToLLVM/Passes.h"
#include "triton/Conversion/TritonGPUToLLVM/Passes.h"
#include "triton/Conversion/TritonToTritonGPU/Passes.h"
#include "triton/Target/LLVMIR/Passes.h"

#include "mlir/Dialect/LLVMIR/NVVMDialect.h"
// #include "mlir/Dialect/LLVMIR/ROCDLDialect.h" @EUGO_CHANGE - no ROCM support
#include "mlir/InitAllPasses.h"

// namespace mlir { @EUGO_CHANGE - Don't build tests
// namespace test {
// void registerTestAliasPass();
// void registerTestAlignmentPass();
// void registerTestAllocationPass();
// void registerTestMembarPass();
// } // namespace test
// } // namespace mlir

inline void registerTritonDialects(mlir::DialectRegistry &registry) {
  mlir::registerAllPasses();
  mlir::triton::registerTritonPasses();
  mlir::triton::gpu::registerTritonGPUPasses();
  mlir::registerTritonNvidiaGPUPasses();
  // mlir::test::registerTestAliasPass(); @EUGO_CHANGE - Don't build tests
  // mlir::test::registerTestAlignmentPass(); // @EUGO_CHANGE - Don't build tests
  // mlir::test::registerTestAllocationPass(); // @EUGO_CHANGE - Don't build tests
  // mlir::test::registerTestMembarPass(); // @EUGO_CHANGE - Don't build tests
  mlir::triton::registerConvertTritonToTritonGPUPass();
  mlir::triton::registerRelayoutTritonGPUPass();
  mlir::triton::gpu::registerAllocateSharedMemoryPass();
  mlir::triton::gpu::registerTritonGPUAllocateWarpGroups();
  mlir::triton::gpu::registerTritonGPUGlobalScratchAllocationPass();
  mlir::triton::registerConvertWarpSpecializeToLLVM();
  mlir::triton::registerConvertTritonGPUToLLVMPass();
  mlir::triton::registerConvertNVGPUToLLVMPass();
  mlir::registerLLVMDIScope();

  // TritonAMDGPUToLLVM passes
  // mlir::triton::registerConvertTritonAMDGPUToLLVM(); // @EUGO_CHANGE - no AMD support
  // mlir::triton::registerConvertBuiltinFuncToLLVM(); // @EUGO_CHANGE - no AMD support (this comes from ./third_party/amd/include/TritonAMDGPUToLLVM/Passes.td and is defined like `ConvertBuiltinFuncToLLVM`)
  // mlir::triton::registerDecomposeUnsupportedAMDConversions(); // @EUGO_CHANGE - no AMD support
  // mlir::triton::registerOptimizeAMDLDSUsage(); // @EUGO_CHANGE - no AMD support

  // TritonAMDGPUTransforms passes
  // mlir::registerTritonAMDGPUAccelerateMatmul();  // @EUGO_CHANGE - no AMD support
  // mlir::registerTritonAMDGPUOptimizeEpilogue(); // @EUGO_CHANGE - no AMD support
  // mlir::registerTritonAMDGPUReorderInstructions(); // @EUGO_CHANGE - no AMD support
  // mlir::registerTritonAMDGPUBlockPingpong(); // @EUGO_CHANGE - no AMD support
  // mlir::registerTritonAMDGPUStreamPipeline(); // @EUGO_CHANGE - no AMD support
  // mlir::registerTritonAMDGPUCanonicalizePointers(); // @EUGO_CHANGE - no AMD support
  // mlir::registerTritonAMDGPUConvertToBufferOps(); // @EUGO_CHANGE - no AMD support
  // mlir::triton::registerTritonAMDGPUInsertInstructionSchedHints(); // @EUGO_CHANGE - no AMD support
  // mlir::triton::registerTritonAMDGPULowerInstructionSchedHints(); // @EUGO_CHANGE - no AMD support

  // TODO: register Triton & TritonGPU passes
  registry
      .insert<mlir::triton::TritonDialect, mlir::cf::ControlFlowDialect,
              mlir::triton::nvidia_gpu::TritonNvidiaGPUDialect,
              mlir::triton::gpu::TritonGPUDialect, mlir::math::MathDialect,
              mlir::arith::ArithDialect, mlir::scf::SCFDialect,
              mlir::gpu::GPUDialect, mlir::LLVM::LLVMDialect,
              mlir::NVVM::NVVMDialect, mlir::triton::nvgpu::NVGPUDialect,
              mlir::triton::proton::ProtonDialect>();
              // mlir::triton::amdgpu::TritonAMDGPUDialect, // @EUGO_CHANGE - no AMD support
              // mlir::ROCDL::ROCDLDialect>(); // @EUGO_CHANGE - no ROCM support
}
