
#!/bin/bash

# Ensure we are in the test directory
cd "$(dirname "$0")"

# Create a temporary directory for test artifacts
TEST_DIR=$(mktemp -d)
BUTANE_INPUT="${TEST_DIR}/input.bu"

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

# Run butane and capture stdout
IGNITION_OUTPUT=$(/usr/bin/butane "${BUTANE_INPUT}")

# Check if the captured output contains expected content (a simple check for a known string)
if ! echo "${IGNITION_OUTPUT}" | grep -q "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3b2t0N4j2S..."; then
    echo "Error: Standard output does not contain expected Ignition content."
    echo "Captured output:"
    echo "${IGNITION_OUTPUT}"
    exit 1
fi

echo "Test passed: Butane successfully generated configuration to stdout."

# Clean up temporary directory
rm -rf "${TEST_DIR}"
