# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"
inherit base vcs-snapshot

DESCRIPTION="A collection of POSIX shell scripts to invoke archiver programs"
HOMEPAGE="https://github.com/vaeth/archwrap/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"
RDEPEND="app-shells/push"
DEPEND=""

src_install() {
	local i
	insinto /usr/bin
	for i in bin/*
	do	if test -h "${i}" || ! test -x "${i}"
		then	doins "${i}"
		else	dobin "${i}"
		fi
	done
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins zsh/*
	fi
	dodoc README
}
