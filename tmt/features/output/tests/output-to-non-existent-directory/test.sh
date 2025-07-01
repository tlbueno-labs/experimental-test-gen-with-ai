
#!/bin/bash

# Ensure we are in the test directory
cd "$(dirname "$0")"

# Create a temporary directory for test artifacts
TEST_DIR=$(mktemp -d)
BUTANE_INPUT="${TEST_DIR}/input.bu"
NON_EXISTENT_DIR="${TEST_DIR}/nonexistent_dir"
IGNITION_OUTPUT="${NON_EXISTENT_DIR}/output.ign"

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

# Run butane with --output to a non-existent directory and expect failure
/usr/bin/butane --output="${IGNITION_OUTPUT}" "${BUTANE_INPUT}"
EXIT_CODE=$?

# Check if butane exited with a non-zero status code (failure expected)
if [[ ${EXIT_CODE} -eq 0 ]]; then
    echo "Error: Butane unexpectedly succeeded when writing to a non-existent directory."
    rm -rf "${TEST_DIR}"
    exit 1
fi

# Verify that the non-existent directory was NOT created
if [[ -d "${NON_EXISTENT_DIR}" ]]; then
    echo "Error: Non-existent directory '${NON_EXISTENT_DIR}' was created."
    rm -rf "${TEST_DIR}"
    exit 1
fi

# Verify that the output file was NOT created
if [[ -f "${IGNITION_OUTPUT}" ]]; then
    echo "Error: Output file '${IGNITION_OUTPUT}' was created unexpectedly."
    rm -rf "${TEST_DIR}"
    exit 1
fi

echo "Test passed: Butane correctly failed when writing to a non-existent directory."

# Clean up temporary directory
rm -rf "${TEST_DIR}"
