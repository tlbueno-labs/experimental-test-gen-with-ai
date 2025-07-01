
#!/bin/bash

# Ensure we are in the test directory
cd "$(dirname "$0")"

# Create a temporary directory for test artifacts
TEST_DIR=$(mktemp -d)
BUTANE_INPUT="${TEST_DIR}/input.bu"
IGNITION_OUTPUT="${TEST_DIR}/output.ign"

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

# Run butane with --output
/usr/bin/butane --output="${IGNITION_OUTPUT}" "${BUTANE_INPUT}"

# Check if the output file was created
if [[ ! -f "${IGNITION_OUTPUT}" ]]; then
    echo "Error: Output file '${IGNITION_OUTPUT}' was not created."
    exit 1
fi

# Check if the output file contains expected content (a simple check for a known string)
if ! grep -q "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3b2t0N4j2S..." "${IGNITION_OUTPUT}"; then
    echo "Error: Output file '${IGNITION_OUTPUT}' does not contain expected Ignition content."
    exit 1
fi

echo "Test passed: Butane successfully generated configuration to '${IGNITION_OUTPUT}'."

# Clean up temporary directory
rm -rf "${TEST_DIR}"
