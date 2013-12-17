# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A wrapper for cp -i -a, making use of diff"
HOMEPAGE="https://github.com/vaeth/cpi/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- bin/cpi || die
	epatch_user
}

src_install() {
	dobin bin/cpi
	insinto /usr/bin
	doins bin/mvi
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
