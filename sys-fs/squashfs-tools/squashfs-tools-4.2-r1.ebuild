# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils toolchain-funcs

MY_PV=${PV}
DESCRIPTION="Tool for creating compressed filesystem type squashfs"
HOMEPAGE="http://squashfs.sourceforge.net"
SRC_URI="mirror://sourceforge/squashfs/squashfs${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-linux"
IUSE="lzma lzo +progress-redirect xattr +xz"

RDEPEND="
	sys-libs/zlib
	xz? ( app-arch/xz-utils )
	lzo? ( dev-libs/lzo )
	lzma? ( app-arch/xz-utils )
	xattr? ( sys-apps/attr )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/squashfs${MY_PV}/squashfs-tools

src_prepare() {
	use progress-redirect && \
		epatch "${FILESDIR}/${PN}-4.0-progress-stderr.patch"
	epatch_user
}

use_sed() {
	local u=$1 s="${2:-`echo $1 | tr '[:lower:]' '[:upper:]'`}_SUPPORT"
	printf '/^#?%s =/%s\n' "${s}" \
		"$( use $u && echo s:.*:${s} = 1: || echo d )"
}

src_configure() {
	tc-export CC
	sed -i -r \
		-e "$(use_sed xz XZ)" \
		-e "$(use_sed lzo)" \
		-e "$(use_sed xattr)" \
		-e "$(use_sed lzma LZMA_XZ)" \
		Makefile || die
}

src_install() {
	dobin mksquashfs unsquashfs
	cd .. || die
	dodoc README ACKNOWLEDGEMENTS CHANGES PERFORMANCE.README
}

pkg_postinst() {
	ewarn "This version of mksquashfs requires a 2.6.29 kernel or better"
	use xz &&
		ewarn "XZ support requires a 2.6.38 kernel or better"
}
