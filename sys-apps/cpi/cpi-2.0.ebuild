# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A wrapper for cp -i -a, making use of diff"
HOMEPAGE="https://github.com/vaeth/cpi/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"

src_prepare() {
	epatch_user
}

src_install() {
	dobin bin/*
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins zsh/*
	fi
}
