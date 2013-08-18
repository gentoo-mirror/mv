# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils systemd vcs-snapshot

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="zsh-completion"

RDEPEND="dev-lang/perl
	sys-fs/squashfs-tools
	!<app-shells/runtitle-2.3
	zsh-completion? ( app-shells/runtitle[zsh-completion] )
	!<sys-fs/unionfs-fuse-0.25"
DEPEND=""

src_prepare() {
	epatch_user
}

src_install() {
	dobin bin/*
	dodoc README
	doinitd openrc/init.d/*
	systemd_dounit systemd/system/*
	insinto /etc
	doins etc/*
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
		doins zsh/*
	fi
}

pkg_postinst() {
	if ! has_version sys-fs/squashfs-tools[progress-redirect]
	then	elog "For better output of ${PN}, it is recommended to install"
		elog "sys-fs/squashfs-tools from the mv overlay with USE=progress-redirect"
	fi
	has_version app-shells/runtitle || elog \
		"Install app-shells/runtitle to let ${PN} update the status bar"
}
