# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

inherit rpm
RESTRICT="mirror"

MY_PN="smpppd"
MY_PV="${PV%.*}"
MY_P="${MY_PN}-${MY_PV}-${PV##*.}"
S="${WORKDIR}/${MY_PN}-${MY_PV}"
DESCRIPTION="Give statistics about dialup connections. Originally part of SuSE's smpppd"
HOMEPAGE="http://www.opensuse.org"
SRC_URI="http://download.opensuse.org/distribution/10.2/repo/src-oss/suse/src/${MY_P}.src.rpm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

test -z "${ACCOUNTING_LOG}" && ACCOUNTING_LOG="/var/log/accounting.log"

CDIR="${S}/smpppd"
DDIR="${S}/doc"

DEPEND=">=net-dialup/ppp-2.4.4-r13"
RDEPEND="${DEPEND}"

src_unpack() {
	rpm_src_unpack
	echo "#define VERSION ${MY_PV}" >"${CDIR}"/config.h
	sed -i -e's!^\(#define ACCOUNTING_LOG \).*$!\1"'"${ACCOUNTING_LOG}"'"!' \
		"${CDIR}"/defines.h
	sed -i -e's!/var/log/[^.]*\.log!'"${ACCOUNTING_LOG}"'!' \
		"${DDIR}"/accounting.1
	sed -i -e '/#include <string>/i#include <cstring>' "${CDIR}"/parse.h
	sed -i -e '/#include <string>/i#include <cstring>\n#include <cstdlib>\n#include <algorithm>' "${CDIR}"/utils.h
	sed -i -e '/#include <string>/i#include <cstdlib>' "${CDIR}"/accounting.h
}

src_compile() {
	cd "${CDIR}"
	g++ ${CXXFLAGS} ${LDFLAGS} -o accounting \
		accounting.cc utils.cc format.cc parse.cc tempus.cc filter.cc \
		|| die "compiling failed"
}

new_sedbin() {
	dodir "${2%/*}"
	sed -e "s!ACCOUNTING_LOG!${ACCOUNTING_LOG}!" -- "${1}" >"${D}/${2}"
	fperms 755 "${2}"
}

src_install() {
	cd "${CDIR}"
	dobin accounting
	cd "${DDIR}"
	doman accounting.1
	new_sedbin "${FILESDIR}"/ip-up.sh   /etc/ppp/ip-up.d/80-accounting.sh
	new_sedbin "${FILESDIR}"/ip-down.sh /etc/ppp/ip-down.d/10-accounting.sh
}

pkg_postinst() {
	ewarn "The accounting tool only interprets ${ACCOUNTING_LOG}"
	ewarn "This file is updated by scripts in /etc/ppp/ip-up.d and /etc/ppp/ip-down.d"
	ewarn "You might want to modify these scripts (e.g. add provider info)."
}
