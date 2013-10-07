# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

WANT_LIBTOOL=none
EGIT_REPO_URI="git://git.samba.org/ccache.git"
inherit autotools eutils git-r3 multilib

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
	epatch "${FILESDIR}"/${PN}-3.1.7-no-perl.patch #421609
	sed \
		-e "/^LIBDIR=/s:lib:$(get_libdir):" \
		-e "/^EPREFIX=/s:'':'${EPREFIX}':" \
		"${FILESDIR}"/ccache-config-2 > ccache-config || die
	epatch_user
	eautoreconf
}

src_install() {
	default
	dodoc AUTHORS.txt MANUAL.txt NEWS.txt README.txt

	dobin ccache-config
#	rm -rfv -- "${D}/root"
}

pkg_prerm() {
	if [[ -z ${REPLACED_BY_VERSION} ]] ; then
		"${EROOT}"/usr/bin/ccache-config --remove-links
		"${EROOT}"/usr/bin/ccache-config --remove-links ${CHOST}
	fi
}

pkg_postinst() {
	"${EROOT}"/usr/bin/ccache-config --install-links
	"${EROOT}"/usr/bin/ccache-config --install-links ${CHOST}

	# nuke broken symlinks from previous versions that shouldn't exist
	rm -f "${EROOT}/usr/$(get_libdir)/ccache/bin/${CHOST}-cc"
	[[ -d "${EROOT}/usr/$(get_libdir)/ccache.backup" ]] && \
		rm -rf "${EROOT}/usr/$(get_libdir)/ccache.backup"

	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		elog "To use ccache with **non-Portage** C compiling, add"
		elog "${EPREFIX}/usr/$(get_libdir)/ccache/bin to the beginning of your path, before ${EPREFIX}/usr/bin."
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
	if has_version "<${CATEGORY}/${PN}-3.1.9-r2" ; then
		elog "ccache now supports sys-devel/clang and dev-lang/icc, too!"
	fi
}
