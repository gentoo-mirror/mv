# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A POSIX shell wrapper for wc, supporting compressed files (xz, lzma, bz2, gz)"
HOMEPAGE="https://github.com/vaeth/set_prompt/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	epatch_user
}

src_install() {
	insinto /etc
	doins set_prompt.config
	insinto /usr/bin
	doins set_prompt.sh git_prompt.zsh
	dobin set_prompt
	dodoc README
}
