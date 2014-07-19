# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils systemd

DESCRIPTION="script to schedule jobs in a multiuser multitasking environment"
HOMEPAGE="https://github.com/vaeth/starter/"
SRC_URI="https://github.com/vaeth/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="dev-lang/perl"
DEPEND=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-e 's"^/usr/share/schedule"${EPREFIX}/usr/share/${PN}"' \
		-e '/^use FindBin;/,/^\}$/d' \
		-- bin/* || die
	epatch_user
}

src_install() {
	dobin bin/*
	dodoc README ChangeLog
	insinto "/usr/share/${PN}"
	doins -r lib/*
	doinitd openrc/init.d/*
	systemd_dounit systemd/system/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
