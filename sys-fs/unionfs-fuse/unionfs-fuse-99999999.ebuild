# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
EHG_REPO_URI="http://podgorny.cz/~bernd/hg/hgwebdir.cgi/0.25"
S="${WORKDIR}/0.25"
inherit mercurial flag-o-matic

DESCRIPTION="Self-syncing tree-merging file system based on FUSE"

HOMEPAGE="http://podgorny.cz/moin/UnionFsFuse"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

PROPERTIES="live"

DEPEND="sys-fs/fuse"
RDEPEND="${DEPEND}"

src_configure() {
	filter-flags -flto -fuse-linkerplugin -fwhole-program -fno-common
}

src_compile() {
	emake PREFIX="${EPREFIX}/usr" BINDIR=/sbin
}

src_install() {
	dodir /usr/sbin /usr/share/man/man8
	emake PREFIX="${EPREFIX}/usr" BINDIR=/sbin DESTDIR="${ED}" install
}
