# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI=2
inherit autotools
RESTRICT="mirror"

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://www.mathematik.uni-wuerzburg.de/~vaeth/gentoo/index.html"
SRC_URI="http://www.mathematik.uni-wuerzburg.de/~vaeth/gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="hack-squash-utils +unionfs-fuse"

RDEPEND="sys-fs/squashfs-tools
	unionfs-fuse? ( sys-fs/unionfs-fuse )"
DEPEND=">=sys-devel/autoconf-2.65
	>=sys-devel/automake-1.10"

src_prepare () {
	eautoreconf
}

src_configure () {
	econf $(use_enable hack-squash-utils squashfs-tools-patch) \
		--with-decompress="${PORTAGE_COMPRESS} -dc --" \
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	prepalldocs
}
