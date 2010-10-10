# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
inherit eutils toolchain-funcs
RESTRICT="mirror"

MY_P="${P/-tools/}"
DESCRIPTION="Compressed in-memory swap device for Linux"
HOMEPAGE="http://code.google.com/p/compcache/"
SRC_URI="http://compcache.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${MY_P}/sub-projects/rzscontrol"

src_prepare() {
	epatch "${FILESDIR}/${PN}-cc.patch"
}

src_compile() {
	tc-export CC
	default
}

src_install() {
	dobin rzscontrol || die
	doman man/rzscontrol.1 || die
	newinitd "${FILESDIR}/compcache.initd" compcache
	newconfd "${FILESDIR}/compcache.confd" compcache
}

pkg_postinst() {
	elog
	elog "To use compcache, add ramzswap support to your kernel and add compcache"
	elog "to your default runlevel (\"rc-config add compcache default\")."
	elog
}
