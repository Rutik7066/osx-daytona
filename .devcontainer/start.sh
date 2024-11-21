#!/bin/bash
    set -eux

# Initialize necessary paths and permissions
sudo touch /dev/kvm /dev/snd "${IMAGE_PATH:-/home/arch/OSX-KVM/mac_hdd_ng.img}" "${BOOTDISK:-}" "${ENV:-/env}" 2>/dev/null || true
sudo chown -R $(id -u):$(id -g) /dev/kvm /dev/snd "${IMAGE_PATH}" "${BOOTDISK}" "${ENV}" 2>/dev/null || true

# Logic for NOPICKER environment
if [[ "${NOPICKER}" == "true" ]]; then
    sed -i '/^.*InstallMedia.*/d' /home/arch/OSX-KVM/Launch.sh
    export BOOTDISK="${BOOTDISK:=/home/arch/OSX-KVM/OpenCore/OpenCore-nopicker.qcow2}"
else
    export BOOTDISK="${BOOTDISK:=/home/arch/OSX-KVM/OpenCore/OpenCore.qcow2}"
fi

# Generate unique boot disk if requested
if [[ "${GENERATE_UNIQUE}" == "true" ]]; then
    /home/arch/OSX-KVM/Docker-OSX/osx-serial-generator/generate-unique-machine-values.sh \
        --master-plist-url="${MASTER_PLIST_URL}" \
        --count 1 \
        --tsv ./serial.tsv \
        --bootdisks \
        --width "${WIDTH:-1920}" \
        --height "${HEIGHT:-1080}" \
        --output-bootdisk "${BOOTDISK}" \
        --output-env "${ENV}" || exit 1
fi

# Generate specific boot disk if requested
if [[ "${GENERATE_SPECIFIC}" == "true" ]]; then
    source "${ENV}" 2>/dev/null
    /home/arch/OSX-KVM/Docker-OSX/osx-serial-generator/generate-specific-bootdisk.sh \
        --master-plist-url="${MASTER_PLIST_URL}" \
        --model "${DEVICE_MODEL}" \
        --serial "${SERIAL}" \
        --board-serial "${BOARD_SERIAL}" \
        --uuid "${UUID}" \
        --mac-address "${MAC_ADDRESS}" \
        --width "${WIDTH:-1920}" \
        --height "${HEIGHT:-1080}" \
        --output-bootdisk "${BOOTDISK}" || exit 1
fi

# Start the macOS environment
/home/arch/OSX-KVM/enable-ssh.sh
exec /bin/bash -c /home/arch/OSX-KVM/Launch.sh
