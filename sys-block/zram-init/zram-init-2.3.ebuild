# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils systemd vcs-snapshot

DESCRIPTION="Scripts to support compressed swap devices or ramdisks with zram"
HOMEPAGE="https://github.com/vaeth/zram-init/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	epatch_user
}

src_install() {
	dosbin sbin/*
	doinitd openrc/init.d/*
	doconfd openrc/conf.d/*
	systemd_dounit systemd/system/*
	insinto /etc/modprobe.d
	doins etc/modprobe.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}

pkg_postinst() {
	elog "To use zram, activate it in your kernel and add it to default runlevel:"
	elog "	rc-config add zram default"
	elog "If you use systemd enable zram_swap, tmp, and/or var_tmp with systemctl."
	elog "You might need to modify /etc/modprobe.d/zram.conf"
}
