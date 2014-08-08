# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils readme.gentoo systemd

DESCRIPTION="script to schedule jobs in a multiuser multitasking environment"
HOMEPAGE="https://github.com/vaeth/starter/"
SRC_URI="https://github.com/vaeth/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="dev-lang/perl
	virtual/perl-File-Path
	virtual/perl-File-Spec
	virtual/perl-Getopt-Long
	>=virtual/perl-IO-1.280.0"
# Smaller versions of perl-IO are untested and therefore not recommended
DEPEND=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="It is recommended to put a lengthy passphrase into the first line
of /etc/schedule.password and to change permission so that only users allowed
to access the system schedule-server can read it.

You might want to adapt /etc/conf.d/schedule to your needs.
If you use systemd, you might want to override schedule.service locally in
/etc/systemd/system to adapt it to your needs."

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
	doconfd openrc/conf.d/*
	systemd_dounit systemd/system/*
	doenvd env.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}

pkg_postinst() {
	optfeature "colored output" 'virtual/perl-Term-ANSIColor'
	optfeature "encryption support" 'dev-perl/Crypt-Rijndael virtual/perl-Digest-SHA'
}
