# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
inherit latex-package eutils
RESTRICT="mirror"

DESCRIPTION="Finds out useless references in latex files or numbered environments that should not be"
HOMEPAGE="http://www-ljk.imag.fr/membres/Jerome.Lelong/soft/chklref/index.html"
SRC_URI="http://www-ljk.imag.fr/membres/Jerome.Lelong/soft/chklref/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="virtual/latex-base
	dev-lang/perl"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/posix.patch
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
