# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit linux-info toolchain-funcs eutils

DESCRIPTION="Modern rewrite of Quick Image Viewer"
HOMEPAGE="http://github.com/phillipberndt/pqiv http://www.pberndt.com/Programme/Linux/pqiv/"
SRC_URI="https://github.com/phillipberndt/pqiv/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk2 kernel_linux"

RDEPEND="dev-libs/glib:2
	x11-libs/cairo
	gtk2? ( x11-libs/gtk+:2 )
	!gtk2? ( x11-libs/gtk+:3 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

pkg_setup() {
	if use kernel_linux; then
		CONFIG_CHECK="~INOTIFY_USER"
		linux-info_pkg_setup
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-ldflags.patch
	epatch_user
}

src_configure() {
	local gtkver=3
	! use gtk2 || gtkver=2
	./configure --gtk-version=${gtkver} --prefix=/usr --destdir="${D}" || die
}

src_compile() {
	tc-export CC
	emake CFLAGS="${CFLAGS}"
}

src_install() {
	default
	dodoc README.markdown
}
