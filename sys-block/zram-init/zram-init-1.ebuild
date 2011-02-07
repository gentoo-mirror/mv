# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"

DESCRIPTION="Initscript support for compressed ramdisks or swap devices"
HOMEPAGE="http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=drivers/staging/zram/zram.txt;hb=HEAD"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}"

src_install() {
	newinitd "${FILESDIR}/zram.initd" zram
	newconfd "${FILESDIR}/zram.confd" zram
}

pkg_postinst() {
	elog
	elog "To use zram, activate it in your kernel and add it to default runlevel:"
	elog "rc-config add zram default"
	elog
}
