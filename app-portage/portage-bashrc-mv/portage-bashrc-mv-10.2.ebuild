# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"

DESCRIPTION="Provide support for /etc/portage/bashrc.d and /etc/portage/package.cflags"
HOMEPAGE="https://github.com/vaeth/${PN}"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_unpack() {
	default
	cd *"${PN}"-*
	S="${PWD}"
}

src_install() {
	insinto /etc/portage
	doins -r bashrc bashrc.d
	docompress /etc/portage/bashrc.d/README
}
