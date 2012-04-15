# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit base linux-mod eutils

ARCHRUMP="${PN}-full-${PV}"
DESCRIPTION="Winmodems with Lucent Apollo (ISA) and Mars (PCI) chipsets"
HOMEPAGE="http://linmodems.technion.ac.il/"
SRC_URI="http://linmodems.technion.ac.il/packages/ltmodem/kernel-2.6/martian/${ARCHRUMP}.tar.gz"

LICENSE="GPL-2 AgereSystems-WinModem"
KEYWORDS="-* ~x86"
IUSE=""

RESTRICT="mirror strip"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${ARCHRUMP}"

MODULE_NAMES="martian_dev(ltmodem::kmodule)"
CONFIG_CHECK="SERIAL_8250"
SERIAL_8250_ERROR="This driver requires you to compile your kernel with serial core (CONFIG_SERIAL_8250) support."

PATCHES=("${FILESDIR}/grsecurity.patch")

pkg_setup() {
	linux-mod_pkg_setup

	if kernel_is lt 2 6 21
	then	eerror "This driver works only with 2.6.21 or newer kernels!"
		die "unsupported kernel detected"
	fi

	BUILD_TARGETS="all"
	BUILD_PARAMS="KERNEL_DIR='${KV_DIR}' SUBLEVEL='21'"
}

src_install() {
	# install kernel module
	linux-mod_src_install
	dosbin modem/martian_modem
}

pkg_postinst() {
	linux-mod_pkg_postinst

	[ "$ROOT" = "/" ] && /sbin/update-modules

	ewarn
	ewarn "To make the modem available modprobe martian_dev and run \"martian_modem\"."
	ewarn "This will make the modem available as /dev/ttySM0."
	ewarn "When using wvdial add \"Carrier Check = no\" line."
}
