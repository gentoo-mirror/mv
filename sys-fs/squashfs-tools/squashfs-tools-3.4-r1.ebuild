# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit base toolchain-funcs

MY_PV=${PV/_p/-r}
DESCRIPTION="Tool for creating compressed filesystem type squashfs"
HOMEPAGE="http://squashfs.sourceforge.net/"
SRC_URI="mirror://sourceforge/squashfs/squashfs${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="3.1" # squashfs filesystem version
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="+progress-redirect"

RDEPEND="sys-libs/zlib"

S="${WORKDIR}/squashfs${MY_PV}/squashfs-tools"

src_prepare() {
	sed -i \
		-e 's:-O2:$(CFLAGS):' \
		-e '/-lz/s:$: $(LDFLAGS):' \
		Makefile || die "sed failed"
	use progress-redirect && \
		epatch "${FILESDIR}/${P}-progress-stderr.patch"
	sed -i -e 's:get_nprocs():sysconf(_SC_NPROCESSORS_ONLN):' *.c
	base_src_prepare
}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_install() {
	newbin mksquashfs mksquashfs-${SLOT} || die
	newbin unsquashfs unsquashfs-${SLOT} || die
	cd ..
	dodoc README ACKNOWLEDGEMENTS CHANGES PERFORMANCE.README README
}
