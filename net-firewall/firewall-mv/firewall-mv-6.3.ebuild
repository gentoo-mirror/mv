# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"
inherit base vcs-snapshot

DESCRIPTION="Initialize iptables and net-related sysctl variables"
HOMEPAGE="https://github.com/vaeth/firewall-mv/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_prepare() {
	sed -i \
		-e "s!/etc/!${EPREFIX%/}/etc/!g" \
		-e "s!/usr/!${EPREFIX%/}/usr/!g" \
		firewall \
		firewall.config
	base_src_prepare
}

src_install() {
	into /
	dosbin firewall sysctl.net
	insinto /etc
	doins firewall.config
	doconfd openrc/conf.d/*
	doinitd openrc/init.d/*
	dodoc README
}
