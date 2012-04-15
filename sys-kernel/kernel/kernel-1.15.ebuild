# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"
inherit base vcs-snapshot

DESCRIPTION="A POSIX shell script to compile the kernel with user permissions"
HOMEPAGE="https://github.com/vaeth/kernel/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+eix zsh-completion"

RDEPEND="app-admin/sudo
	app-admin/sudox
	eix? ( app-portage/eix )"

src_install() {
	dobin "${PN}"
}
