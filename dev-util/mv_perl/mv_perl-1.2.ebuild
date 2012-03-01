# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"

DESCRIPTION="A collection of perl scripts (replacement in files, syncing dirs etc)"
HOMEPAGE="https://github.com/vaeth/${PN}"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"

RDEPEND="dev-lang/perl
	virtual/perl-Getopt-Long
	virtual/perl-Digest-MD5"

src_unpack() {
	default
	cd *"${PN}"-*
	S="${PWD}"
}

src_install() {
	dobin bin/*
	dodoc README
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins zsh/_*
	fi
}
