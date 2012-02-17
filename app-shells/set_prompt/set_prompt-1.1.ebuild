# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"

DESCRIPTION="A POSIX shell wrapper for wc, supporting compressed files (xz, lzma, bz2, gz)"
HOMEPAGE="https://github.com/vaeth/${PN}"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_unpack() {
	default
	cd *"${PN}"-*
	S="${PWD}"
}

src_install() {
	insinto /etc
	doins set_prompt.config
	dobin set_prompt set_prompt.sh git_prompt.zsh
	dodoc README
}
