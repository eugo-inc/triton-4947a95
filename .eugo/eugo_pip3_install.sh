#!/usr/bin/env bash
# @EUGO_CHANGE
# Quick local install for smoke-testing this fork after an upstream merge.
# Targets Linux with CUDA installed (CUDA-only fork — see CLAUDE.md).
#
# Usage:
#   bash .eugo/eugo_pip3_install.sh
#
# Required (or override via env):
#   EUGO_CUDA_PATH   default: /usr/local/cuda
#   EUGO_LLVM_PATH   default: /opt/llvm_toolchain
#
# Optional:
#   TRITON_CACHE_PATH        default: $HOME/.triton/cache
#   JSON_INCLUDE_DIR         default: /usr/include
#   EUGO_TRITON_PIP_EXTRA    extra args appended to `pip3 install` (e.g. "--target /opt/foo")

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

cuda_path="${EUGO_CUDA_PATH:-/usr/local/cuda}"
llvm_path="${EUGO_LLVM_PATH:-/opt/llvm_toolchain}"

if [[ ! -d "$cuda_path" ]]; then
  echo "ERROR: CUDA path not found: $cuda_path. Set EUGO_CUDA_PATH." >&2
  exit 1
fi
if [[ ! -d "$llvm_path" ]]; then
  echo "ERROR: LLVM path not found: $llvm_path. Set EUGO_LLVM_PATH." >&2
  exit 1
fi

# Prefer per-arch CUDA target paths if present (Eugo's standard layout); fall back to flat.
arch="$(uname -m)"
case "$arch" in
  aarch64|arm64) cuda_target_dir="$cuda_path/targets/sbsa-linux" ;;
  x86_64)        cuda_target_dir="$cuda_path/targets/x86_64-linux" ;;
  *)             cuda_target_dir="" ;;
esac

if [[ -n "$cuda_target_dir" && -d "$cuda_target_dir/include" ]]; then
  cupti_inc="$cuda_target_dir/include"
  cupti_lib="$cuda_target_dir/lib"
else
  cupti_inc="$cuda_path/include"
  cupti_lib="$cuda_path/lib64"
fi

triton_cache_path="${TRITON_CACHE_PATH:-$HOME/.triton/cache}"
mkdir -p "$triton_cache_path"

cmake_args=(
  -DBUILD_SHARED_LIBS=ON
  -DTRITON_BUILD_PYTHON_MODULE=ON
  -DTRITON_CODEGEN_BACKENDS=nvidia
  -DTRITON_BUILD_PROTON=ON
  -DEUGO_TRITON_BUILD_APPS=OFF
  -DTRITON_BUILD_UT=OFF
  -DTRITON_BUILD_WITH_CCACHE=OFF
  -DBUILD_TESTING=OFF
  -DLLVM_SYSPATH="$llvm_path"
  -DTRITON_CACHE_PATH="$triton_cache_path"
  -DCUPTI_INCLUDE_DIR="$cupti_inc"
  -DCUPTI_LIB_DIR="$cupti_lib"
  -DROCTRACER_INCLUDE_DIR=/tmp
  -DJSON_INCLUDE_DIR="${JSON_INCLUDE_DIR:-/usr/include}"
)

export CMAKE_ARGS="${cmake_args[*]}"

echo "[eugo] repo:               $repo_root"
echo "[eugo] arch:               $arch"
echo "[eugo] CUDA path:          $cuda_path"
echo "[eugo] LLVM path:          $llvm_path"
echo "[eugo] CUPTI inc:          $cupti_inc"
echo "[eugo] CUPTI lib:          $cupti_lib"
echo "[eugo] TRITON_CACHE_PATH:  $triton_cache_path"
echo "[eugo] CMAKE_ARGS:         $CMAKE_ARGS"

# shellcheck disable=SC2086
pip3 install --no-build-isolation -v "$repo_root" ${EUGO_TRITON_PIP_EXTRA:-}
