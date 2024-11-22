#!/bin/bash

set -e

echo "Setting up host environment..."


if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    echo "Failed to setup Osx: Unsupported OS."
    exit 1
fi




case "$OS" in
    arch)
        sudo pacman -Syu --noconfirm qemu libvirt dnsmasq virt-manager bridge-utils flex bison iptables-nft edk2-ovmf
        ;;
    ubuntu|debian)
        sudo apt update
        sudo apt install -y qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools
        ;;
    centos|rhel|fedora)
        sudo yum install -y libvirt qemu-kvm
        ;;
    *)
        echo "Unsupported Linux distribution: $OS. Exiting."
        exit 1
        ;;
esac


sudo systemctl enable --now libvirtd
sudo systemctl enable --now virtlogd
echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs > /dev/null
sudo modprobe kvm

echo "Host setup complete."
