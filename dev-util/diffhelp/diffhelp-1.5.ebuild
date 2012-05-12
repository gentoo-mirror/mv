# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A frontend, beautifier, and path-fixer for diff -u"
HOMEPAGE="https://github.com/vaeth/diffhelp/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"

src_prepare() {
	epatch_user
}

src_install() {
	dobin "${PN}"
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins "_${PN}"
	fi
}
