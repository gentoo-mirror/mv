# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="find cruft files not managed by portage"
HOMEPAGE="https://github.com/vaeth/find_cruft/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"

RDEPEND="dev-lang/perl
	virtual/perl-Getopt-Long"

src_prepare() {
	epatch_user
}

src_install() {
	dobin bin/*
	dodoc README
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins zsh/_*
	fi
}
