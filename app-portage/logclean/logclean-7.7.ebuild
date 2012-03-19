# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"
inherit vcs-snapshot

DESCRIPTION="Keep only (compressed) logs of installed packages"
HOMEPAGE="https://github.com/vaeth/logclean/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+eix zsh-completion"

RDEPEND="dev-lang/perl
	virtual/perl-Getopt-Long
	eix? ( app-portage/eix )"

src_install() {
	dobin "${PN}"
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins "_${PN}"
	fi
}
