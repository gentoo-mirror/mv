# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="find cruft files not managed by portage"
HOMEPAGE="https://github.com/vaeth/find_cruft/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/perl
	virtual/perl-Getopt-Long"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	epatch_user
}

src_install() {
	dobin bin/*
	dodoc README
	insinto /etc
	doins etc/*
	dodir /etc/find_cruft.d
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}

pkg_postinst() {
	optfeature "faster execution" 'app-portage/eix'
}
