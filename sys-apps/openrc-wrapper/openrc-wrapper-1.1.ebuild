# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils systemd vcs-snapshot

DESCRIPTION="Use openrc init scripts with systemd or other init systems"
HOMEPAGE="http://github.com/vaeth/openrc-wrapper"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND=""
IUSE="zsh-completion"

src_prepare() {
	epatch_user
}

src_install() {
	dobin bin/*
	systemd_dounit systemd/system/*
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
		doins zsh/*
	fi
}
