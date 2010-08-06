# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"

inherit multilib
RESTRICT="mirror"

DESCRIPTION="fast compiler cache"
HOMEPAGE="http://ccache.samba.org/"
MY_P="${P/_/}"
SRC_URI="http://samba.org/ftp/ccache/${MY_P}.tar.bz2"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+defaults"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"

do_links() {
	local a b
	for a in gcc c++ g++
	do	for b in "${CHOST}"- ''
		do	dosym "${EROOT%/}/usr/bin/ccache" \
			"${EPREFIX%/}/usr/$(get_libdir)/ccache/bin/${b}${a}"
		done
	done
}

src_install() {
	if use defaults
	then	echo 'CCACHE_SLOPPINESS="file_macro,time_macros,include_file_mtime"
CCACHE_COMPRESS=1' >"${S}/98ccache"
		doenvd "${S}/98ccache"
	fi
	dobin ccache || die
	doman ccache.1
	dodoc README.txt NEWS.txt

	diropts -m0755
	dodir "${EPREFIX%/}/usr/$(get_libdir)/ccache/bin"
	keepdir "${EPREFIX%/}/usr/$(get_libdir)/ccache/bin"

	dobin "${FILESDIR}"/ccache-config || die
}

pkg_preinst() {
	if [ "${ROOT}" = "/" ]
	then	einfo "Scanning for compiler front-ends..."
		do_links
	else	ewarn "Install is incomplete; you must run the following commands:"
		ewarn " # ccache-config --install-links"
		ewarn " # ccache-config --install-links ${CHOST}"
		ewarn "after booting or chrooting to ${ROOT} to complete installation."
	fi
}

pkg_postinst() {
	local i
	# nuke broken symlinks from previous versions that shouldn't exist
	for i in cc "${CHOST}"-cc
	do	test -L "${ROOT}/usr/$(get_libdir)/ccache/bin/${i}" && \
			rm -rf -- "${ROOT}/usr/$(get_libdir)/ccache/bin/${i}"
	done
	test -d "${ROOT}/usr/$(get_libdir)/ccache.backup" && \
		rm -rf -- "${ROOT}/usr/$(get_libdir)/ccache.backup"

	elog "To use ccache with **non-Portage** C compiling, add"
	elog "/usr/$(get_libdir)/ccache/bin to the beginning of your path, before /usr/bin."
	elog "Portage can will automatically take advantage of ccache if you use"
	elog "FEATURES=ccache"
	elog "If this is your first install of ccache, type something like this"
	elog "to set a maximum cache size of 4GB:"
	elog "	CCACHE_DIR=\"${CCACHE_DIR:-${PORTAGE_TMPDIR}/ccache}\"ccache -M 4G"
	elog
	elog "If you are upgrading from an older version than 3.x you should run"
	elog "	CCACHE_DIR=\"${CCACHE_DIR:-${PORTAGE_TMPDIR}/ccache}\" ccache -C"
	elog "You should do the same when you change the gcc version, since"
	elog "ccache's compiler check acts in gentoo only on gentoo's gcc wrapper."
	elog "It can lead to strange errors when you forget to do this after a"
	elog "compiler change."
	if use defaults
	then	elog
		elog "Observe that some default choices are made in /etc/env.d/98ccache"
	fi

	case "${PORTAGE_TMPDIR}/portage/*" in
		"${CCACHE_BASEDIR:-none}"/*) :;;
		*)
		ewarn "To make optimal use of ccache with portage, please set"
		ewarn "	CCACHE_BASEDIR=\"\${PORTAGE_TMPDIR}/portage\""
		ewarn "in your /etc/make.conf";;
	esac
}
