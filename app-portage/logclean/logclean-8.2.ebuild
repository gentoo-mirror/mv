# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="Keep only (compressed) logs of installed packages"
HOMEPAGE="https://github.com/vaeth/logclean/"
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
	dobin "${PN}"
	insinto /etc
	doins "${PN}.conf"
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins "_${PN}"
	fi
}

pkg_postinst() {
	has_version app-portage/eix || \
		elog "Installing app-portage/eix will speed up execution time"
}
