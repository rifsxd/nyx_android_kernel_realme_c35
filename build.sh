#!/bin/bash

# Display usage help
function usage() {
    echo "Usage: $0 <action> [additional-options]"
    echo
    echo "Actions:"
    echo "  config   Configure the kernel build."
    echo "  compile  Compile the kernel."
    echo "  dtc      Compile device tree blobs (DTBs)."
    echo "  clean    Remove build artifacts."
    echo
}


# Check if an argument is passed
if [ -z "$0" ]; then
    usage
fi

# Check if export.env exists and source it
if [ -f "export.env" ]; then
    source "export.env"
else
    echo "Error: export.env not found in the current directory."
    exit 1
fi

# Define the base command with shared options
base_command='make ARCH="arm64" O="out" CC="clang" CLANG_TRIPLE="aarch64-linux-gnu-" CROSS_COMPILE="aarch64-linux-android-" CROSS_COMPILE_ARM32="arm-linux-androideabi-" LD="ld.lld" AR="llvm-ar" NM="llvm-nm" OBJCOPY="llvm-objcopy" OBJDUMP="llvm-objdump" READELF="llvm-readelf" OBJSIZE="llvm-size" STRIP="llvm-strip" LDGOLD="aarch64-linux-gnu-ld.gold" LLVM_AR="llvm-ar" LLVM_DIS="llvm-dis" BSP_BUILD_ANDROID_OS="y" BSP_BUILD_FAMILY="qogirl6"'

# Execute the respective command based on the input
case "$1" in
    clean)
        eval "rm -rf out kernel_log.log"
        ;;
    kernelsu)
        eval "./KernelSU/kernel/setup.sh next"
        ;;
    config-stock)
        eval "$base_command realme_c35_nyx_defconfig"
        ;;
    config-ksu)
        eval "$base_command realme_c35_nyx_ksu_defconfig"
        ;;
    config-ksu-susfs-auto)
        eval "$base_command realme_c35_nyx_ksu_susfs_auto_defconfig"
        ;;
    config-ksu-susfs-manual)
        eval "$base_command realme_c35_nyx_ksu_susfs_manual_defconfig"
        ;;
    compile)
        eval "$base_command -j$(nproc) 2>&1 | tee ./out/kernel_log.log"
        ;;
    dtc)
        eval "$base_command -j$(nproc) dtbs"
        ;;
    *)
        usage
        ;;
esac
