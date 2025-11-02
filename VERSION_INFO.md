# Version Information

Last updated: 2025-11-02

## KernelSU-Next
- **Repository**: https://github.com/rifsxd/KernelSU-Next
- **Branch**: `next`
- **Latest Commit**: `0fc4b726ac` (Oct 29, 2025)
- **Latest Release**: v1.1.1 HOTFIX (Sep 21, 2025)
- **Status**: ✅ Up-to-date

## SUSFS (Kernel 5.4)
- **Repository**: https://gitlab.com/simonpunk/susfs4ksu (branch: kernel-5.4)
- **Version**: v1.5.5
- **Last Updated**: Oct 16, 2024
- **Files**:
  - `fs/susfs.c` (916 lines)
  - `include/linux/susfs.h` (186 lines)
  - `include/linux/susfs_def.h`
- **Status**: ✅ Up-to-date (latest stable for kernel 5.4.x)

## Notes
- SUSFS v1.5.5 is the latest stable version for Linux kernel 5.4.x
- SUSFS versions 1.5.6+ are for newer kernel versions (5.10, 5.15, 6.1+)
- KernelSU-Next branch corrected from `next-susfs` (non-existent) to `next`
- All source files verified identical to official repository

## Build Configurations
- `realme_c35_nyx_ksu.config.json` - KernelSU only (branch: `next`)
- `realme_c35_nyx_ksu_stable.config.json` - KernelSU stable (v1.0.3)
- `realme_c35_nyx_ksu_susfs.config.json` - KernelSU + SUSFS (branch: `next`)
