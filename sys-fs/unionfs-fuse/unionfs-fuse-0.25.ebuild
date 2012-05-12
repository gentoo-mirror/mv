# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit eutils flag-o-matic
RESTRICT="mirror"
DESCRIPTION="Self-syncing tree-merging file system based on FUSE"

HOMEPAGE="http://podgorny.cz/moin/UnionFsFuse"
SRC_URI="http://podgorny.cz/unionfs-fuse/releases/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-fs/fuse"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch_user
}

src_configure() {
	filter-flags -flto -fuse-linkerplugin -fwhole-program -fno-common
}

src_compile() {
	emake PREFIX="${EPREFIX}/usr" BINDIR=/sbin
}

src_install() {
	dodir /usr/sbin /usr/share/man/man8
	emake DESTDIR="${ED}" PREFIX="${EPREFIX}/usr" install
}
