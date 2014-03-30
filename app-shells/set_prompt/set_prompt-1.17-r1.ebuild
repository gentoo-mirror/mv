# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="An intelligent prompt for zsh or bash with status line (window title) support"
HOMEPAGE="https://github.com/vaeth/set_prompt/"
SRC_URI="https://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- * || die
	epatch_user
}

src_install() {
	insinto /etc
	doins set_prompt.config
	insinto /usr/bin
	doins set_prompt.sh git_prompt.zsh
	dobin set_prompt
	dodoc README
}
