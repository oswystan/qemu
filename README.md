########################################################
# WHY
> This project is used for helping kernel engineer or hobbyist to develop kernel code on PC.
> I hope it can help you.
> I have run these commands on ubuntu14.04. It does not need graphic UI. Only command line is OK.

## install qemu
```
sudo apt-get install qemu
```

# HOWTO
## download kernel src and build
```
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.7.tar.xz
tar xvf linux-4.7.tar.xz
cd linux-4.7
make defconfig
make -j 10
cd ..
```
## make ramfs
```
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
```

## busybox setup
```
wget http://busybox.net/downloads/busybox-1.25.0.tar.bz2
tar jxvf busybox-1.25.0.tar.bz2
cp busybox_qemu_defconfig busybox-1.25.0/configs/
cd busybox-1.25.0
make busybox_qemu_defconfig
make -j 10
sudo make install CONFIG_PREFIX=../rootfs
sudo umount ../rootfs
cd ..
```

## start kernel
```
qemu-system-x86_64 -m 128 -kernel linux-4.7/arch/x86_64/boot/bzImage -hda rootfs.img -append "root=/dev/sda init=/sbin/init console=ttyS0" -nographic
```

## keys for qemu
```
C-a+x       - exit qemu
```

########################################################
