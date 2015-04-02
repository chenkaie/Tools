#!/bin/sh
#
# sudo rmmod ubifs ubi nandsim nand mtdblock mtd_blkdevs cmdlinepart mtd

usage()
{
  echo "usage: $(basename "$0") [mount | umount]"
}

mount_ubi()
{
	lsmod |grep nandsim > /dev/null
	if [ $? -ne 0 ]; then
		modprobe mtdblock
		modprobe ubi
		modprobe nandsim first_id_byte=0x20 second_id_byte=0xaa third_id_byte=0x00 fourth_id_byte=0x15
		chmod 660 /dev/mtd*
		mkdir /mnt/ubi/
	fi

	dd if=root.ubi of=/dev/mtdblock0
	ubiattach /dev/ubi_ctrl -m 0
	mount -t ubifs ubi0_0 /mnt/ubi
}

umount_ubi()
{
	umount /mnt/ubi/
	ubidetach -m 0
}

[ $# -le 1 ] || { usage; exit 1; }

case "$1" in
	"mount")    mount_ubi  ;;
	"umount")   umount_ubi ;;
	*)          usage      ;;
esac
