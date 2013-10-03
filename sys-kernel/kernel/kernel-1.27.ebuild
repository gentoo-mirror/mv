# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A POSIX shell script to compile the kernel with user permissions"
HOMEPAGE="https://github.com/vaeth/kernel/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

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
	epatch_user
}

src_install() {
	dobin "${PN}"
	insinto /usr/share/zsh/site-functions
	doins _*
}

pkg_postinst() {
	has_version app-portage/eix || \
		elog "Installing app-portage/eix will speed up ${PN}"
	has_version app-shells/runtitle || elog \
		"Install app-shells/runtitle to let ${PN} update the status bar"
}
