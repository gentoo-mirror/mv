# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A POSIX shell script to compile the kernel with user permissions"
HOMEPAGE="https://github.com/vaeth/kernel/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="app-admin/sudo
	app-admin/sudox
	app-shells/push
	>=app-shells/runtitle-2.3"
DEPEND=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- "${PN}" || die
	epatch_user
}

src_install() {
	dobin "${PN}"
	insinto /usr/share/zsh/site-functions
	doins _*
}

pkg_postinst() {
	optfeature "faster execution" 'app-portage/eix'
	optfeature "status bar support" 'app-shells/runtitle'
}
