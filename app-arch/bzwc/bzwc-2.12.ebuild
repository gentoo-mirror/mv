# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A POSIX shell wrapper for wc, supporting compressed files (xz, lzma, bz2, gz)"
HOMEPAGE="https://github.com/vaeth/bzwc/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"
RDEPEND="app-shells/push"
DEPEND=""

src_prepare() {
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
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins zsh/*
	fi
}
