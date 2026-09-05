#!/usr/bin/env bash
set -euo pipefail

PYODIDE_XBUILDENV_VERSION="${PYODIDE_XBUILDENV_VERSION:-20260401}"
RUST_TOOLCHAIN="${RUST_TOOLCHAIN:-1.93.0}"
XBUILDENV_PATH="${XBUILDENV_PATH:-${HOME}/.cache/pyodide-build/xbuildenv-${PYODIDE_XBUILDENV_VERSION}}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname -- "${SCRIPT_DIR}")"
OUTDIR="${OUTDIR:-${REPO_ROOT}/target/pyodide-wheels}"

uvx --from pyodide-build pyodide xbuildenv install \
    "${PYODIDE_XBUILDENV_VERSION}" \
    --nightly \
    --path "${XBUILDENV_PATH}"

rustup target add wasm32-unknown-emscripten --toolchain "${RUST_TOOLCHAIN}"

cd "${REPO_ROOT}/pywellen"

RUSTUP_TOOLCHAIN="${RUST_TOOLCHAIN}" \
uvx --from pyodide-build pyodide build \
    --xbuildenv-path "${XBUILDENV_PATH}" \
    --outdir "${OUTDIR}"
