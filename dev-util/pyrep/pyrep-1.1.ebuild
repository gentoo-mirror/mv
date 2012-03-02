# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"

DESCRIPTION="Search and/or replace regular expressions within many files interactively"
HOMEPAGE="https://github.com/vaeth/${PN}"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/python"

src_unpack() {
	default
	cd *"${PN}"-*
	S="${PWD}"
}

src_install() {
	dobin "${PN}"
}
