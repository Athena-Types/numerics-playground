# Helper function to run commands in Docker
# Requires TIMEOUT variable to be set before sourcing this file
# Optional: MEMORY_LIMIT (default 10g), CPU_LIMIT (default 1)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEMORY_LIMIT=${MEMORY_LIMIT:-10g}
CPU_LIMIT=${CPU_LIMIT:-1}
ERROR_LOG="${SCRIPT_DIR}/benchmarks-new/failures.log"

run_in_docker() {
    local cmd="$*"
    timeout "$TIMEOUT" sudo docker run --rm \
        --memory="$MEMORY_LIMIT" \
        --memory-swap="$MEMORY_LIMIT" \
        --cpus="$CPU_LIMIT" \
        -v "$SCRIPT_DIR/benchmarks-new:/numerics-playground/benchmarks-new" \
        -w /numerics-playground \
        negfuzz \
        bash -c "source ~/.bashrc && /usr/bin/time -v $cmd" || {
            exit_code=$?
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            if [ $exit_code -eq 124 ]; then
                echo "WARNING: Command timed out after ${TIMEOUT}s: $cmd" >&2
                echo "[$timestamp] TIMEOUT (${TIMEOUT}s): $cmd" >> "$ERROR_LOG"
            elif [ $exit_code -eq 137 ]; then
                echo "WARNING: OOM killed (limit: ${MEMORY_LIMIT}): $cmd" >&2
                echo "[$timestamp] OOM (${MEMORY_LIMIT}): $cmd" >> "$ERROR_LOG"
            else
                echo "ERROR: Exit code $exit_code: $cmd" >&2
                echo "[$timestamp] FAILED ($exit_code): $cmd" >> "$ERROR_LOG"
            fi
            return 0
        }
}
