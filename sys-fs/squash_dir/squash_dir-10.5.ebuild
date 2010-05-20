# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
inherit autotools
RESTRICT="mirror"

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://www.mathematik.uni-wuerzburg.de/~vaeth/gentoo/index.html"
SRC_URI="http://www.mathematik.uni-wuerzburg.de/~vaeth/gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="readonly"

RDEPEND="sys-fs/squashfs-tools
	!readonly? ( || (
		sys-fs/aufs2
		>sys-fs/unionfs-fuse-0.24
		sys-fs/funionfs
		sys-fs/unionfs
		sys-fs/aufs
	) )"
DEPEND=">=sys-devel/autoconf-2.65"

src_prepare () {
	eautoreconf
}

src_configure () {
	econf --docdir="${EPREFIX}/usr/share/doc/${PF}"
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	prepalldocs
}

check_for_obsolete () {
	local a
	a="${EPREFIX}/etc/portage/env/sys-fs/squashfs-tools"
	test -e "${a}" && grep -q "squash_dir's hack" "${a}" || return 0
	ewarn "You probably had installed ${PN} with USE=hack-squash-utils"
	ewarn "${a} is left from this."
	ewarn "This file is now obsolete."
	ewarn "It is recommended to remove it and to install instead"
	ewarn "sys-fs/squashfs-tools from the mv overlay with USE=progress-redirect"
	return 1
}

pkg_postinst () {
	check_for_obsolete && \
		! has_version sys-fs/squashfs-tools[progress-redirect] || return 0
	ewarn "For better output of ${PN}, it is recommended to install"
	ewarn "sys-fs/squashfs-tools from the mv overlay with USE=progress-redirect"
	:
}

pkg_postrm () {
	check_for_obsolete
	:
}
