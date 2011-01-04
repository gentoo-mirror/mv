# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit linux-mod eutils

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

pkg_setup() {
	linux-mod_pkg_setup

	if kernel_is 2 4
	then	eerror "This driver works only with 2.6 kernels!"
		die "unsupported kernel detected"
	fi

	BUILD_TARGETS="all"
	BUILD_PARAMS="KERNEL_DIR='${KV_DIR}' SUBLEVEL='${KV_PATCH}'"
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

	if linux_chkconfig_present SMP
	then	ewarn
		ewarn "Please note that Linux support for SMP (symmetric multi processor)"
		ewarn "is reported to be incompatible with this driver!"
		ewarn "In case it doesn't work, you should try first to disable CONFIG_SMP in your kernel."
	fi
}
