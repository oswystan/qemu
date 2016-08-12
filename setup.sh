#!/bin/bash

function setup_linux() {
    echo "setup linux ..."
    wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.7.tar.xz
    tar xvf linux-4.7.tar.xz
    cd linux-4.7
    make defconfig
    make -j 10
    cd ..
}

function setup_busybox() {
    echo "setup busybox ..."
    wget http://busybox.net/downloads/busybox-1.25.0.tar.bz2
    tar jxvf busybox-1.25.0.tar.bz2
    cp busybox_qemu_defconfig busybox-1.25.0/configs/
    cd busybox-1.25.0
    make busybox_qemu_defconfig
    make -j 10
    sudo make install CONFIG_PREFIX=../rootfs
    sudo umount ../rootfs
    cd ..
}

function setup_rootfs() {
    echo "setup rootfs ..."
    dd if=/dev/zero of=rootfs.img bs=1M count=16
    mkfs.ext4 -F rootfs.img
    mkdir rootfs
    sudo mount -t ext4 -o loop rootfs.img rootfs
    cd rootfs
    sudo mkdir -p dev proc sys etc/init.d
    sudo cp ../rcS etc/init.d/
    sudo cp ../fstab etc/
    sudo cp ../profile etc/
    cd ..
}

function main() {
    setup_rootfs
    setup_linux
    setup_busybox
}

###################################
main
