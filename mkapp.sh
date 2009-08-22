#!/bin/sh
# Script for project make file
case "$0" in
	*vivaldi*)
	export soc_platform=vivaldi
	export BUILDROOTDIR=/opt/Vivotek/lsp/buildroot-2.0.0.0
	export VIVALDIDIR=/opt/Vivotek/lsp/vivaldi-2.0.0.0
	export TOOLSDIR=${BUILDROOTDIR}/build_arm_nofpu/staging_dir/bin
	export PRJROOT=${VIVALDIDIR}
	export TARGET=arm-linux
	export PREFIX=${PRJROOT}/tools
	export TARGET_PREFIX=${PREFIX}/${TARGET}
	export PATH=${TOOLSDIR}:${PREFIX}/bin:${PATH}
	export MODULEINC=${PRJROOT}/kernel/modules/include
	export KERNELINC=${PRJROOT}/kernel/linux-2.4/include
	;;
	*bach*)
	export soc_platform=bach
	export LSPDIR=/opt/Vivotek/lsp/bach
	export BUILDROOTDIR=${LSPDIR}/buildroot
	export PROJECT=kernel_platform_sq
	export PRJROOT=${LSPDIR}/${PROJECT}
	export PATH="$PATH:${BUILDROOTDIR}/build_arm_nofpu/staging_dir/bin"
	export KERNELINC=${PRJROOT}/kernel/linux-2.6/include
	export KERNELSRC=${PRJROOT}/kernel/linux-2.6
	;;
	*haydn*)
	export soc_platform=haydn
	#export LSPDIR=/opt/Vivotek/lsp/haydn
	export LSPDIR=/opt/Vivotek/lsp/haydnEABI
	export BUILDROOTDIR=${LSPDIR}/buildroot
	export PATH="$PATH:${BUILDROOTDIR}/build_arm_nofpu/staging_dir/bin"
	;;
    *dm355*)
    export soc_platform=dm355
    export LSPDIR=/opt/Vivotek/lsp/DM355
    export PROJECT=kernel_platform
    export PRJROOT=${LSPDIR}/${PROJECT}
    export TOOLSDIR="/opt/montavista/pro5.0/devkit/arm/v5t_le/bin"
	#export TOOLSDIR="/opt/montavista/pro/devkit/arm/v5t_le/bin"
    export TARGET=arm-linux
    export PREFIX=${PRJROOT}/tools
    export TARGET_PREFIX=${PREFIX}/${TARGET}
    export PATH="${TOOLSDIR}:${PREFIX}/bin:/opt/montavista/pro5.0/bin:/opt/montavista/common/bin:${PATH}"
    ;;
	*dm365*)
    export soc_platform=dm365
    export LSPDIR=/opt/Vivotek/lsp/DM365
    export PROJECT=kernel_platform
    export PRJROOT=${LSPDIR}/${PROJECT}
    export TOOLSDIR="/opt/montavista/pro5.0/devkit/arm/v5t_le/bin"
    export TARGET=arm-linux
    export PREFIX=${PRJROOT}/tools
    export TARGET_PREFIX=${PREFIX}/${TARGET}
    export PATH="${TOOLSDIR}:${PREFIX}/bin:/opt/montavista/pro5.0/bin:/opt/montavista/common/bin:${PATH}"
    ;;
	*)
	exit 1
	;;
esac

echo soc_platform=$soc_platform

export PROJ_ROOT=~/project/Horus/app_cluster
export BUILD_ROOT=~/work/Horus/${soc_platform}/build
export ROOTFSDIR=~/work/Horus/${soc_platform}/rootfs

make soc_platform=$soc_platform BUILD_ROOT=$BUILD_ROOT $@

exit 0
