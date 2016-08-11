########################################################
# install qemu
sudo apt-get install qemu

# download kernel src and build
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.7.tar.xz
tar xvf linux-4.7.tar.xz
cd linux-4.7
make defconfig
make -j 10

# make ramfs
dd if=/dev/zero of=rootfs.img bs=1M count=10
mkfs.ext4 rootfs.img
mkdir rootfs
sudo mount -t ext4 -o loop rootfs.img rootfs
cd rootfs
sudo mkdir -p dev proc sys etc/init.d
cp ../rcS etc/init.d/
cp ../fstab etc/

# busybox setup
wget http://busybox.net/downloads/busybox-1.25.0.tar.bz2
tar jxvf busybox-1.25.0.tar.bz2
cp busybox_qemu_defconfig busybox-1.25.0/configs/
cd busybox-1.25.0
make busybox_qemu_defconfig
make -j 10
make install CONFIG_PREFIX=../rootfs/
sudo umount ../rootfs

# start kernel
qemu-system-x86_64 -kernel linux-4.7/arch/x86_64/boot/bzImage -hda rootfs.img -append "root=/dev/sda init=/sbin/init console=ttyS0" -nographic

# keys for qemu
C-a+x       - exit qemu

########################################################
