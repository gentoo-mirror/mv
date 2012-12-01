# Copyright 1999-2012 Gentoo Foundation
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
IUSE="+title zsh-completion"
RDEPEND="app-admin/sudo
	app-admin/sudox
	app-shells/push
	title? ( >=app-shells/runtitle-2.3[zsh-completion?] )"
DEPEND=""

src_prepare() {
	epatch_user
}

src_install() {
	dobin "${PN}"
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins _*
	fi
}

pkg_postinst() {
	has_version app-portage/eix || \
		elog "Installing app-portage/eix will speed up execution time"
}
