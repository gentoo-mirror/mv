# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A collection of perl scripts (replacement in files, syncing dirs etc)"
HOMEPAGE="https://github.com/vaeth/mv_perl/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/perl
	virtual/perl-File-Spec
	virtual/perl-Getopt-Long
	virtual/perl-Digest-MD5
	virtual/perl-Time-HiRes"

src_prepare() {
	epatch_user
}

src_install() {
	dobin bin/*
	dodoc README
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}
