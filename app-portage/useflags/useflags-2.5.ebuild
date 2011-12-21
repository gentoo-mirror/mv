# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"

DESCRIPTION="Print or save the current USE-flag state and compare with older versions"
HOMEPAGE="https://github.com/vaeth/${PN}"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"
PROPERTIES="live"

src_unpack() {
	default
	cd *"${PN}"-*
	S="${PWD}"
}

src_install() {
	dobin "${PN}"
	if use zsh-completion
	then	insinto ${EPREFIX%/}/usr/share/zsh/site-functions
			doins "_${PN}"
	fi
}
