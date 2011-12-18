# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"

EGIT_REPO_URI="git://github.com/vaeth/${PN}.git"
[ -n "${EVCS_OFFLINE}" ] || EGIT_REPACK=true
inherit git-2

DESCRIPTION="Provide support for /etc/portage/bashrc.d and /etc/portage/package.cflags"
HOMEPAGE="https://github.com/vaeth/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
PROPERTIES="live"

src_install() {
	insinto "${EPREFIX%/}/etc/portage"
	doins -r bashrc bashrc.d
}
