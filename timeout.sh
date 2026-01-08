# Helper function to run commands with timeout
# Requires TIMEOUT variable to be set before sourcing this file
run_with_timeout() {
    timeout "$TIMEOUT" "$@" || {
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo "WARNING: Command timed out after ${TIMEOUT}s: $*" >&2
        else
            echo "ERROR: Command failed with exit code $exit_code: $*" >&2
        fi
        return 0  # Continue execution
    }
}
