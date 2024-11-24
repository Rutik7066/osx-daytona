#!/bin/bash

set -euo pipefail  # Fail on unset variables and any command error

echo "Setting up host environment..."

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
else
    echo "Cannot determine Linux distribution. Exiting."
    exit 1
fi

echo "Detected OS: $OS"

# Install required packages based on distribution
case "$OS" in
    arch)
        echo "Installing dependencies for Arch Linux..."
        sudo pacman -Syu --noconfirm qemu libvirt dnsmasq virt-manager bridge-utils flex bison iptables-nft edk2-ovmf
        ;;
    ubuntu|debian)
        echo "Installing dependencies for Ubuntu/Debian..."
        sudo apt install qemu-system-x86 qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools
        ;;
    centos|rhel|fedora)
        echo "Installing dependencies for CentOS/RHEL/Fedora..."
        sudo yum install -y qemu-kvm libvirt libvirt-daemon-system libvirt-clients virt-manager
        ;;
    *)
        echo "Unsupported Linux distribution: $OS. Exiting."
        exit 1
        ;;
esac

# Enable and start libvirt services
echo "Enabling and starting libvirt services..."

sudo systemctl enable --now libvirtd
sudo systemctl enable --now virtlogd

echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs

sudo modprobe kvm

echo "Host setup complete."
