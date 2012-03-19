# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"

inherit vcs-snapshot elisp-common

DESCRIPTION="A collection of perl scripts (replacement in files, syncing dirs etc)"
HOMEPAGE="https://github.com/vaeth/mv_emacs/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

PDEPEND="virtual/emacs"

src_install() {
	insinto "${SITELISP}/mv_emacs"
	doins *.el
	dodoc README
}
