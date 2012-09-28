# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit cmake-utils eutils flag-o-matic multilib vcs-snapshot

DESCRIPTION="If a command is not found (bash/zsh), search ARCH database for packages with similar commands"
HOMEPAGE="https://github.com/metti/command-not-found/"
SRC_URI="http://github.com/metti/${PN}/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON="sys-libs/tdb"
DEPEND="${COMMON}"
RDEPEND="${COMMON}"

S="${WORKDIR}/${P}/src"

src_prepare() {
	PREFIX=${EPREFIX}
	filter-flags -fwhole-program
	sed -i -e 1d -e '2i#! /bin/sh' cnf-cron.in || die
	sed -i \
		-e "s!usr/lib!usr/$(get_libdir)!g" \
		-e "/^INSTALL.*cnf\.sh/,/^INSTALL/{/EXECUTE/d}" \
		CMakeLists.txt || die
	sed -i -e "s/function[[:space:]]*\([^[:space:](]*\)[[:space:]]*(/\1(/" \
		cnf.sh || die
	epatch_user
}

src_install() {
	keepdir /var/lib/cnf
	cmake-utils_src_install
}
