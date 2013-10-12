# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils readme.gentoo systemd vcs-snapshot

DESCRIPTION="Scripts to support compressed swap devices or ramdisks with zram"
HOMEPAGE="https://github.com/vaeth/zram-init/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="To use zram, activate it in your kernel and add it to default runlevel:
	rc-config add zram default
If you use systemd enable zram_swap, tmp, and/or var_tmp with systemctl.
You might need to modify /etc/modprobe.d/zram.conf"

src_prepare() {
	epatch_user
}

src_install() {
	dosbin sbin/*
	doinitd openrc/init.d/*
	doconfd openrc/conf.d/*
	systemd_dounit systemd/system/*
	insinto /etc/modprobe.d
	doins modprobe.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	readme.gentoo_src_install
}
