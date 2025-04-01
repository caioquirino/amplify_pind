#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

SWAP_FILE="/swap/swapfile"
SWAP_SIZE_BLOCKS=4096

# 1. Ensure swap file exists (create + set perms if not found)
if [ ! -f "${SWAP_FILE}" ]; then
    sudo /usr/bin/dd if=/dev/zero of=${SWAP_FILE} bs=1M count=${SWAP_SIZE_BLOCKS} status=none
    sudo /bin/chmod 600 ${SWAP_FILE}
fi

# 2. Ensure swap is activated
# Check using `swapon --show` (same as swapon -s). If the file isn't listed (`grep -q` fails),
# format it as swap (mkswap is safe if already formatted) and turn it on.
if ! sudo /sbin/swapon --show | grep -q "^${SWAP_FILE}\s"; then
    sudo /sbin/mkswap ${SWAP_FILE} > /dev/null # Format, suppress output
    sudo /sbin/swapon ${SWAP_FILE}            # Activate
fi

# Execute the CMD passed to the container
exec "$@"