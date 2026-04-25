# Ubuntu Touch (d2s) - Source Manifests

This directory contains the necessary manifest configuration to pull the required source code for building Halium / Ubuntu Touch for the Samsung Galaxy Note 10+ (SM-N975F / d2s).

## Prerequisites
Building Halium requires a Linux environment (Ubuntu 20.04/22.04 is recommended) and the `repo` tool. Since this project is hosted on macOS, it is highly recommended to either:
1. Use a Linux virtual machine (VM) or a dedicated Linux server.
2. Set up a Docker container with the necessary build dependencies.

## Instructions

1. **Initialize the Halium Repository**
   Create a working directory on your Linux build environment and initialize the Halium manifest. Here we use the Halium 11 (Android 11) base:
   ```bash
   mkdir halium-workspace && cd halium-workspace
   repo init -u https://github.com/Halium/android -b halium-11.0 --depth=1
   ```

2. **Copy the Local Manifest**
   Copy the `roomservice.xml` from this repository to your Halium `.repo/local_manifests/` folder.
   ```bash
   mkdir -p .repo/local_manifests
   cp /path/to/Ubuntu-Touch-d2s/halium/local_manifests/roomservice.xml .repo/local_manifests/
   ```

3. **Sync the Sources**
   Sync the repositories. This will download the LineageOS device trees, common tree, kernel, and vendor blobs.
   ```bash
   repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags
   ```

4. **Apply Halium Patches**
   Depending on the device, you will need to apply specific Halium patches to the kernel and Android system before building. We will configure `halium-boot` and `systemimage` in the next steps.
