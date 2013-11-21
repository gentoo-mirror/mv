# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A collection of POSIX shell scripts to invoke archiver programs"
HOMEPAGE="https://github.com/vaeth/archwrap/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="app-shells/push"
DEPEND=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"$(command -v sh)"'"' \
		-- bin/* || die
	epatch_user
}

src_install() {
	local i
	insinto /usr/bin
	for i in bin/*
	do	if test -h "${i}" || ! test -x "${i}"
		then	doins "${i}"
		else	dobin "${i}"
		fi
	done
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	dodoc README
}
