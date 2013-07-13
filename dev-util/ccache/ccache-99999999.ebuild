# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

WANT_LIBTOOL=none
EGIT_REPO_URI="git://git.samba.org/ccache.git"
[ -n "${EVCS_OFFLINE}" ] || EGIT_REPACK=true
inherit autotools eutils git multilib

DESCRIPTION="fast compiler cache"
HOMEPAGE="http://ccache.samba.org/"
#SRC_URI="http://samba.org/ftp/ccache/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

src_prepare() {
	# make sure we always use system zlib
	rm -rf zlib
	sed \
		-e "/^LIBDIR=/s:lib:$(get_libdir):" \
		"${FILESDIR}"/ccache-config > ccache-config || die
	epatch "${FILESDIR}"/ccache-clang.patch
	epatch_user
	eautoreconf
}

src_install() {
	default
	dodoc AUTHORS.txt MANUAL.txt NEWS.txt README.txt

	dobin ccache-config
	rm -rfv -- "${D}/root"
}

pkg_postinst() {
	"${ROOT}"/usr/bin/ccache-config --install-links
	"${ROOT}"/usr/bin/ccache-config --install-links ${CHOST}

	# nuke broken symlinks from previous versions that shouldn't exist
	rm -f "${ROOT}/usr/$(get_libdir)/ccache/bin/${CHOST}-cc"
	[[ -d "${ROOT}/usr/$(get_libdir)/ccache.backup" ]] && \
		rm -rf "${ROOT}/usr/$(get_libdir)/ccache.backup"

	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		elog "To use ccache with **non-Portage** C compiling, add"
		elog "/usr/$(get_libdir)/ccache/bin to the beginning of your path, before /usr/bin."
		elog "Portage 2.0.46-r11+ will automatically take advantage of ccache with"
		elog "no additional steps."
		elog
		elog "You might want to set a maximum cache size:"
		elog "# ccache -M 2G"
	fi
	if has_version "<${CATEGORY}/${PN}-3" ; then
		elog "If you are upgrading from an older version than 3.x you should clear"
		elog "all of your caches like so:"
		elog "# CCACHE_DIR='${CCACHE_DIR:-${PORTAGE_TMPDIR}/ccache}' ccache -C"
	fi
}
