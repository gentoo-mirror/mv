# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit eutils

DESCRIPTION="dynamic deltup client"
HOMEPAGE="http://linux01.gwdg.de/~nlissne/"
SRC_URI="http://linux01.gwdg.de/~nlissne/${PN}-0.7.8.tar.bz2"
SLOT="0"
IUSE=""
LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~sparc ~x86"
S="${WORKDIR}"

RDEPEND="app-portage/deltup
	dev-util/bdelta"


src_prepare() {
	epatch "${FILESDIR}/eapi2.patch"
	sed -i -e "s:/bin/sh:/bin/bash:" getdelta.sh || die
	epatch_user
}

src_install() {
	dobin "${WORKDIR}"/getdelta.sh
}

pkg_postinst() {
	local a b
	elog "You need to put"
	elog "FETCHCOMMAND=\"/usr/bin/getdelta.sh \\\"\\\${URI}\\\" \\\"\\\${FILE}\\\"\""
	elog "into your /etc/make.conf to make use of getdelta"

	# make sure permissions are ok
	a="${EROOT}"/var/log/getdelta.log
	b="${EROOT}"/etc/deltup
	test -f "${a}" || touch -- "${a}"
	mkdir -p -- "${b}"
	use prefix || chown -R portage:portage -- "${a}" "${b}"
	chmod -R ug+rwX -- "${a}" "${b}"
}
