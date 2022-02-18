# Copyright 2011-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="Create ChangeLog data for gentoo repositories from git"
HOMEPAGE="https://github.com/vaeth/changelog-gitrepo/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE=""

RDEPEND="dev-vcs/git"

src_install() {
	dodoc README.md
	dobin bin/*
}
