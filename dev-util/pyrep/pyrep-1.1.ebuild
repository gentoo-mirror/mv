# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="Search and/or replace regular expressions within many files interactively"
HOMEPAGE="https://github.com/vaeth/pyrep/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/python"

src_prepare() {
	epatch_user
}

src_install() {
	dobin "${PN}"
}
