# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"
inherit base vcs-snapshot

DESCRIPTION="Scripts to support compressed swap devices or ramdisks with zram"
HOMEPAGE="https://github.com/vaeth/zram-init/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"

src_install() {
	dosbin sbin/*
	doinitd openrc/init.d/*
	doconfd openrc/conf.d/*
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
		doins zsh/*
	fi
}

pkg_postinst() {
	elog
	elog "To use zram, activate it in your kernel and add it to default runlevel:"
	elog "rc-config add zram default"
	elog
}
