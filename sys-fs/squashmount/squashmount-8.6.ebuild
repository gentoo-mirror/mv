# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils readme.gentoo systemd

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html
https://github.com/vaeth/squashmount/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="examples"

RDEPEND=">=app-shells/runtitle-2.3
	dev-lang/perl
	|| ( dev-perl/File-Which sys-apps/which )
	virtual/perl-File-Path
	virtual/perl-File-Spec
	virtual/perl-File-Temp
	virtual/perl-Getopt-Long
	sys-fs/squashfs-tools
	!<sys-fs/unionfs-fuse-0.25"
DEPEND=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="Please adapt /etc/squashmount.pl to your needs.
For improved output use squasfs-tools from the mv overlay.
It is recommended to put into your zshrc the line:
alias squashmount='noglob squashmount'"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	epatch_user
}

src_install() {
	dobin bin/*
	dodoc README ChangeLog compress.txt
	doinitd openrc/init.d/*
	systemd_dounit systemd/system/*
	insinto /etc
	if use examples
	then	newins etc/squashmount.pl /squashmount-example.pl
	else	doins etc/squashmount.pl
	fi
	insinto /usr/lib/tmpfiles.d
	doins tmpfiles.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	readme.gentoo_create_doc
}

pkg_postinst() {
	optfeature "status bar support" 'app-shells/runtitle'
	optfeature "improved compatibility and security" 'dev-perl/File-Which'
	optfeature "colored output" 'virtual/perl-Term-ANSIColor'
	optfeature "using ? or ?? attributes" 'virtual/perl-IO-Compress'
	case " ${REPLACING_VERSIONS}" in
	' '[0-9][0-9]*|' '[3-9]*|' '2.[0-9][0-9]*|' '2.[7-9]*)
		:;;
	*)
		FORCE_PRINT_ELOG="true";;
	esac
	readme.gentoo_pkg_postinst
}
