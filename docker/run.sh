# Helper function to run commands in Docker
# Requires TIMEOUT variable to be set before sourcing this file
# Optional: MEMORY_LIMIT (default 10g), CPU_LIMIT (default 1)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEMORY_LIMIT=${MEMORY_LIMIT:-10g}
CPU_LIMIT=${CPU_LIMIT:-1}

run_in_docker() {
    timeout "$TIMEOUT" sudo docker run --rm \
        --memory="$MEMORY_LIMIT" \
        --cpus="$CPU_LIMIT" \
        -v "$SCRIPT_DIR/benchmarks-new:/numerics-playground/benchmarks-new" \
        -w /numerics-playground \
        negfuzz \
        bash -c "source ~/.bashrc && $*" || {
            exit_code=$?
            if [ $exit_code -eq 124 ]; then
                echo "WARNING: Command timed out after ${TIMEOUT}s: $*" >&2
            else
                echo "ERROR: Command failed with exit code $exit_code: $*" >&2
            fi
            return 0  # Continue execution
        }
}
