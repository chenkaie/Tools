#!/bin/sh
#
# sudo rmmod ubifs ubi nandsim nand mtdblock mtd_blkdevs cmdlinepart mtd

usage()
{
	echo "usage: $(basename "$0") <mount | umount> <path-to-ubi-image> <gen>"
}

mount_ubi()
{
	lsmod |grep nandsim > /dev/null
	if [ $? -ne 0 ]; then
		sudo modprobe mtdblock
		sudo modprobe ubi
		sudo modprobe nandsim first_id_byte=0x20 second_id_byte=0xaa third_id_byte=0x00 fourth_id_byte=0x15
		sudo chmod 660 /dev/mtd*
		sudo mkdir /mnt/ubi > /dev/null 2>&1
	fi

	sudo dd if=$UBI_IMAGE of=/dev/mtdblock0

	# Why does ubiattach on a freshly formatted device fail with "Invalid argument"?
	# http://www.linux-mtd.infradead.org/faq/ubi.html#L_vid_offset_mismatch
	case "$GEN" in
		*gen2*)
			sudo ubiattach /dev/ubi_ctrl -m 0
			;;
		*gen3*)
			sudo ubiattach /dev/ubi_ctrl -m 0 -O 2048
			;;
	esac

	sudo mount -t ubifs ubi0 /mnt/ubi
	[ $? -eq 0 ] && echo "Mount successfully on: /mnt/ubi"
}

umount_ubi()
{
	sudo umount /mnt/ubi/
	sudo ubidetach -m 0

	# Due to some speical case, kernel moduels have to be rmmod/insmod to make
	# it work properly under certern condition, e.g.,
	# When you try to ubiattach between two different "VID header offset" image
	# GEN3 => UBI: VID header offset: 2048 (aligned 2048), data offset: 4096
	# GEN2 => UBI: VID header offset: 512  (aligned 512),  data offset: 2048

	lsmod |grep nandsim > /dev/null
	if [ $? -eq 0 ]; then
		sudo rmmod ubifs ubi nandsim nand mtdblock mtd_blkdevs cmdlinepart mtd
	fi
}

[ $# -lt 1 ] && { usage; exit 1; }

UBI_IMAGE="$2"
GEN="$3"

case "$1" in
	"mount")    mount_ubi  ;;
	"umount")   umount_ubi ;;
	*)          usage      ;;
esac
