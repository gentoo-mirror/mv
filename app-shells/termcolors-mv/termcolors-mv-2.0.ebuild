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
IUSE="perl"
REDEPEND="perl? ( dev-lang/perl )"

src_prepare() {
	epatch_user
}

src_install() {
	dodoc README
	dobin bin/dircolors-mv
	use perl && dobin bin/256colors
	insinto /etc
	doins -r etc/*
}

pkg_postinst() {
	case "${REPLACING_VERSIONS:-1.1}" in
	1.1)
		elog "To use the colorschemes of ${PN} call"
		elog "	eval \"\`dircolors-mv\`\""
		elog "e.g. in your bashrc; make sure that SOLARIZED (if desired)"
		elog "and DEFAULTS is set appropriately, see the documentation."
		if ! has_version app-shells/zshrc-mv
		then	elog "For zsh, this happens if you use zshrc-mv"
		fi;;
	esac
}
