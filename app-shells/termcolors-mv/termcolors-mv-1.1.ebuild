# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="256colors sample script and dircolors configuration for standard or 256 colors"
HOMEPAGE="https://github.com/vaeth/termcolors-mv/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	epatch_user
}

src_install() {
	dobin bin/*
	insinto /etc
	doins etc/*
}

pkg_postinst() {
	elog "To use ${PN} with 256 colors, you have to call"
	elog "	eval \"\`dircolors /etc/DIR_COLORS-256\`\""
	elog "e.g. in your bashrc."
	if ! has_version app-shells/zshrc-mv
	then	elog "For zsh, this happens if you use zshrc-mv"
	fi
}
