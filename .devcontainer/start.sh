#!/bin/bash

if ! [[ -e "${BASESYSTEM_IMAGE:-BaseSystem.img}" ]]; then
    printf '%s\n' "No BaseSystem.img available, downloading ${SHORTNAME}"
    make
    qemu-img convert BaseSystem.dmg -O qcow2 -p -c ${BASESYSTEM_IMAGE:-BaseSystem.img}
    rm ./BaseSystem.dmg
fi

sudo touch /dev/kvm /dev/snd "${IMAGE_PATH}" "${BOOTDISK}" "${ENV}" 2>/dev/null || true
sudo chown -R $(id -u):$(id -g) /dev/kvm /dev/snd "${IMAGE_PATH}" "${BOOTDISK}" "${ENV}" 2>/dev/null || true

if [[ "${NOPICKER}" == true ]]; then
    sed -i '/^.*InstallMedia.*/d' Launch.sh
    export BOOTDISK="${BOOTDISK:=/home/arch/OSX-KVM/OpenCore/OpenCore-nopicker.qcow2}"
else
    export BOOTDISK="${BOOTDISK:=/home/arch/OSX-KVM/OpenCore/OpenCore.qcow2}"
fi

if [[ "${GENERATE_UNIQUE}" == true ]]; then
    ./Docker-OSX/osx-serial-generator/generate-unique-machine-values.sh \
        --master-plist-url="${MASTER_PLIST_URL}" \
        --count 1 \
        --tsv ./serial.tsv \
        --bootdisks \
        --width "${WIDTH:-1920}" \
        --height "${HEIGHT:-1080}" \
        --output-bootdisk "${BOOTDISK:=/home/arch/OSX-KVM/OpenCore/OpenCore.qcow2}" \
        --output-env "${ENV:=/env}" \
    || exit 1
fi

if [[ "${GENERATE_SPECIFIC}" == true ]]; then
    source "${ENV:=/env}" 2>/dev/null
    ./Docker-OSX/osx-serial-generator/generate-specific-bootdisk.sh \
        --master-plist-url="${MASTER_PLIST_URL}" \
        --model "${DEVICE_MODEL}" \
        --serial "${SERIAL}" \
        --board-serial "${BOARD_SERIAL}" \
        --uuid "${UUID}" \
        --mac-address "${MAC_ADDRESS}" \
        --width "${WIDTH:-1920}" \
        --height "${HEIGHT:-1080}" \
        --output-bootdisk "${BOOTDISK:=/home/arch/OSX-KVM/OpenCore/OpenCore.qcow2}" \
    || exit 1
fi

./enable-ssh.sh
/bin/bash -c ./Launch.sh
