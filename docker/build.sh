#!/bin/bash

# Available configs: Debug, [RelWithDebInfo], Release
[[ -z "$CONFIG" ]] \
&& config=RelWithDebInfo \
|| config="$CONFIG"
# Available versions: 18.04, [20.04], 22.04
[[ -z "$UBUNTU_VERSION" ]] \
&& ubuntu_version=20.04 \
|| ubuntu_version="$UBUNTU_VERSION"
# Available options: [true], false
[[ -z "$BUILD_SHARED" ]] \
&& build_shared=1 \
|| build_shared="$BUILD_SHARED"
# Available options: [true], false
[[ -z "$BUILD_SERVER" ]] \
&& build_server=1 \
|| build_server="$BUILD_SERVER"
# Available options: true, [false]
[[ -z "$BUILD_TOOLS" ]] \
&& build_tools=0 \
|| build_tools="$BUILD_TOOLS"
# Available options: [x86], x86_64, armv4, armv4i, armv5el, armv5hf, armv6, armv7, armv7hf, armv7s, armv7k, armv8, armv8_32, armv8.3
[[ -z "$TARGET_BUILD_ARCH" ]] \
&& target_build_arch=x86 \
|| target_build_arch="$TARGET_BUILD_ARCH"

dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        cmake \
        ninja-build \
        clang-11 \
        python3-pip \
        gcc-9-multilib \
        g++-9-multilib \
        libstdc++-11-dev:i386 \
    && \
    useradd -m user && \
    su user -c 'pip3 install --user -v "conan==1.57.0"'

EXPORT CC=/usr/bin/clang-11 \
    CXX=/usr/bin/clang++-11 \
    PATH=~/.local/bin:${PATH}

docker build \
    -t open.mp/build:ubuntu-${ubuntu_version} \
    build_ubuntu-${ubuntu_version}/ \
|| exit 1

folders=('build' 'conan')
for folder in "${folders[@]}"; do
    if [[ ! -d "./${folder}" ]]; then
        mkdir ${folder}
    fi
    sudo chown -R 1000:1000 ${folder} || exit 1
done

./docker-entrypoint.sh
