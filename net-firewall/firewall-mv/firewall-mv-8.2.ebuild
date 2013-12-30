# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils systemd vcs-snapshot

DESCRIPTION="Initialize iptables and net-related sysctl variables"
HOMEPAGE="https://github.com/vaeth/firewall-mv/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="app-shells/push"
DEPEND=""

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s!/etc/!${EPREFIX}/etc/!g" \
			-e "s!/usr/!${EPREFIX}/usr/!g" \
			-- sbin/* etc/* systemd/* || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			-- sbin/* || die
	fi
	epatch_user
}

src_install() {
	into /
	dosbin sbin/*
	insinto /etc
	doins -r etc/*
	insinto /usr/lib/modules-load.d
	doins modules-load.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	doconfd openrc/conf.d/*
	doinitd openrc/init.d/*
	dodoc README
	systemd_dounit systemd/*
}
