
#!/bin/bash

# Ensure we are in the test directory
cd "$(dirname "$0")"

# Create a temporary directory for test artifacts
TEST_DIR=$(mktemp -d)
BUTANE_INPUT="${TEST_DIR}/input.bu"
READ_ONLY_DIR="${TEST_DIR}/readonly_dir"
IGNITION_OUTPUT="${READ_ONLY_DIR}/output.ign"

# Create a read-only directory
mkdir -p "${READ_ONLY_DIR}"
chmod 555 "${READ_ONLY_DIR}"

# Butane configuration (using fcos variant as specified)
cat <<EOF > "${BUTANE_INPUT}"
variant: FCOS
version: 1.5.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3b2t0N4j2S...
EOF

# Run butane with --output to a read-only directory and expect failure
/usr/bin/butane --output="${IGNITION_OUTPUT}" "${BUTANE_INPUT}" 2>&1
EXIT_CODE=$?

# Check if butane exited with a non-zero status code (failure expected)
if [[ ${EXIT_CODE} -eq 0 ]]; then
    echo "Error: Butane unexpectedly succeeded when writing to a read-only directory."
    rm -rf "${TEST_DIR}"
    exit 1
fi

# Verify that the output file was NOT created
if [[ -f "${IGNITION_OUTPUT}" ]]; then
    echo "Error: Output file '${IGNITION_OUTPUT}' was created unexpectedly."
    rm -rf "${TEST_DIR}"
    exit 1
fi

echo "Test passed: Butane correctly failed when writing to a directory with insufficient permissions."

# Clean up temporary directory and ensure permissions are restored for cleanup
chmod 755 "${READ_ONLY_DIR}" # Make it writable for cleanup
rm -rf "${TEST_DIR}"
