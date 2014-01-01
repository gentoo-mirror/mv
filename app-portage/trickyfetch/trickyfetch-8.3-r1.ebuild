# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="Plugin for FETCHCOMMAND to help organize and cleanup your DISTDIR"
HOMEPAGE="https://github.com/vaeth/trickyfetch/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s'\\(PATH=.\\)/etc'\\1${EPREFIX}/etc'" \
			-- "${S}/bin/trickyfetch" || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			 -- "${S}"/bin/* || die
	fi
	epatch_user
}

src_install() {
	dobin bin/*
	insinto /etc
	doins etc/*
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
	dodoc README
}

pkg_postinst() {
	case " ${REPLACING_VERSIONS:-0.}" in
	' '[0-7].*)
		elog "Please adapt /etc/trickyfetch.conf to your needs";;
	esac
	has_version app-portage/eix || \
		elog "Installing app-portage/eix will speed up ${PN}"
}
