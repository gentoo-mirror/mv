# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils

DESCRIPTION="A POSIX shell wrapper for wc, supporting compressed files (xz, lzma, bz2, gz)"
HOMEPAGE="https://github.com/vaeth/bzwc/"
SRC_URI="https://github.com/vaeth/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="app-shells/push"
DEPEND=""

src_prepare() {
	local i
	use prefix || for i in bin/*
	do	test -h "${i}" || \
		sed -i -e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' -- "${i}" \
			|| die
	done
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
}
