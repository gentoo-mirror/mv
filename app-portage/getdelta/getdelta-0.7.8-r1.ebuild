# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="2"

inherit eutils

DESCRIPTION="dynamic deltup client"
HOMEPAGE="http://linux01.gwdg.de/~nlissne/"
SRC_URI="http://linux01.gwdg.de/~nlissne/${P}.tar.bz2"
SLOT="0"
IUSE=""
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"

RDEPEND="app-portage/deltup
	dev-util/bdelta"

src_prepare () {
	epatch "${FILESDIR}"/eapi2.patch
}

src_install () {
	sed -i -e "s:/bin/sh:/bin/bash:" "${WORKDIR}"/getdelta.sh || die
	dobin "${WORKDIR}"/getdelta.sh || die
}

pkg_postinst() {
	local a b
	elog "You need to put"
	elog "FETCHCOMMAND=\"/usr/bin/getdelta.sh \\\"\\\${URI}\\\" \\\"\\\${FILE}\\\"\""
	elog "into your /etc/make.conf to make use of getdelta"

	# make sure permissions are ok
	a="${ROOT}"/var/log/getdelta.log
	b="${ROOT}"/etc/deltup
	test -f "${a}" || touch -- "${a}"
	mkdir -p -- "${b}"
	chown -R portage:portage -- "${a}" "${b}"
	chmod -R ug+rwX -- "${a}" "${b}"
}
