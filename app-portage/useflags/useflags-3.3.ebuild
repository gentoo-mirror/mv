# Copyright 1999-2013 Gentoo Foundation
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
		-e '1s"^#!/usr/bin/env perl$"#!'"$(command -v perl)"'"' \
		-- "${PN}" || die
	epatch_user
}

src_install() {
	dobin "${PN}"
	insinto /usr/share/zsh/site-functions
	doins "_${PN}"
}

pkg_postinst() {
	if ! has_version 'app-portage/eix'
	then	elog "Install app-portage/eix for faster execution time."
		elog "With >=app-portage/eix-0.27.7 also security is increased."
	elif has_version '<app-portage/eix-0.27.7'
	then	elog "Upgrade to >=app-portage/eix-0.27.7 to increase security."
	fi
}
