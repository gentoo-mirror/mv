# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A frontend for using mplayer and mencoder as a video recorder"
HOMEPAGE="https://github.com/vaeth/video-mv/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libav +title zsh-completion"
RDEPEND="app-shells/push
	title? ( >=app-shells/runtitle-2.0 )
	!libav? ( media-video/mplayer )
	libav? ( media-video/libav )"
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
	insinto /etc
	doins etc/*
	dodoc README
}
