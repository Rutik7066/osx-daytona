#!/bin/bash
set -eux

# SSH Server Setup
if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
    echo "Initializing SSH server keys..."
    sudo /usr/bin/ssh-keygen -A
fi

echo "Configuring SSH server..."
sudo tee -a /etc/ssh/sshd_config <<EOF
AllowTcpForwarding yes
PermitTunnel yes
X11Forwarding yes
PasswordAuthentication yes
PermitRootLogin yes
PubkeyAuthentication yes
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
EOF

sudo service ssh start

# Initialize macOS Emulation
sudo touch /dev/kvm /dev/snd "${IMAGE_PATH:-/home/arch/OSX-KVM/mac_hdd_ng.img}" "${BOOTDISK:-}" "${ENV:-/env}" 2>/dev/null || true
sudo chown -R $(id -u):$(id -g) /dev/kvm /dev/snd "${IMAGE_PATH}" "${BOOTDISK}" "${ENV}" 2>/dev/null || true

if [[ "${NOPICKER}" == "true" ]]; then
    sed -i '/^.*InstallMedia.*/d' /home/arch/OSX-KVM/Launch.sh
    export BOOTDISK="${BOOTDISK:=/home/arch/OSX-KVM/OpenCore/OpenCore-nopicker.qcow2}"
else
    export BOOTDISK="${BOOTDISK:=/home/arch/OSX-KVM/OpenCore/OpenCore.qcow2}"
fi

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

/home/arch/OSX-KVM/enable-ssh.sh
exec /bin/bash -c /home/arch/OSX-KVM/Launch.sh
