#!/usr/bin/env bash
# Installs the freshly built Pyodide wheel into a Pyodide virtual environment
# and verifies that it imports and reads a small VCD fixture.
#
# Note: run from outside the pywellen source directory; otherwise the .so in
# the source tree shadows the installed package.
set -euo pipefail

PYODIDE_XBUILDENV_VERSION="${PYODIDE_XBUILDENV_VERSION:-314.0.7}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
WHEEL_DIR="${REPO_ROOT}/target/pyodide-wheels"
VENV_DIR="${VENV_DIR:-${REPO_ROOT}/target/pyodide-smoke-venv}"
FIXTURE="${REPO_ROOT}/wellen/inputs/icarus/test1.vcd"

mapfile -t WHEELS < <(find "${WHEEL_DIR}" -maxdepth 1 -name '*.whl' -print)
if [ "${#WHEELS[@]}" -ne 1 ]; then
    echo "expected exactly one wheel in ${WHEEL_DIR}, found: ${#WHEELS[@]}" >&2
    exit 1
fi

rm -rf "${VENV_DIR}"
uvx --from pyodide-build pyodide venv "${VENV_DIR}" >/dev/null
"${VENV_DIR}/bin/pip" install --no-deps --quiet "${WHEELS[0]}"

cd /tmp
"${VENV_DIR}/bin/python" - "${FIXTURE}" <<'EOF'
import sys

from pywellen import Waveform

wave = Waveform(sys.argv[1])
print(f"format: {wave.file_format}")
print(f"vars: {len(wave.all_vars())}")
times = wave.time_table()
print(f"first time: {times[0]}")
print(f"last time: {times[-1]}")

assert wave.file_format == "VCD"
assert len(wave.all_vars()) > 0
assert times[0] is not None
print("pyodide smoke test passed")
EOF
