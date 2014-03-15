# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="Print or save the current USE-flag state and compare with older versions"
HOMEPAGE="https://github.com/vaeth/useflags/"
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
		-- "${PN}" || die
	epatch_user
}

src_install() {
	dobin "${PN}"
	insinto /usr/share/zsh/site-functions
	doins "_${PN}"
}

pkg_postinst() {
	optfeature "faster execution" 'app-portage/eix'
	optfeature "increased security" '>=app-portage/eix-0.27.7'
}
