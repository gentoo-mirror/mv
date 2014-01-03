# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils readme.gentoo systemd vcs-snapshot

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html"
SRC_URI="http://github.com/vaeth/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

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
	dodoc README ChangeLog
	doinitd openrc/init.d/*
	systemd_dounit systemd/system/*
	insinto /etc
	doins etc/*
	insinto /usr/lib/tmpfiles.d
	doins tmpfiles.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	readme.gentoo_src_install
}

pkg_postinst() {
	if ! has_version sys-fs/squashfs-tools[progress-redirect]
	then	elog "For better output of ${PN}, it is recommended to install"
		elog "sys-fs/squashfs-tools from the mv overlay with USE=progress-redirect."
	fi
	has_version app-shells/runtitle || elog \
		"Install app-shells/runtitle to let ${PN} update the status bar."
	has_version dev-perl/File-Which || elog \
		"${PN} strongly recommends to install dev-perl/File-Which."
	has_version '>=dev-lang/perl-5.14' || has_version perl-core/Term-ANSIColor || {
		elog "For colored output upgrade to >=dev-lang/perl-5.14 or"
		elog "alternatively install virtual/perl-Term-ANSIColor"
	}
	has_version '>=dev-lang/perl-5.12' || has_version virtual/perl-IO-Compress || {
		elog "For using ? or ?? attributes upgrade to >=dev-lang/perl-5.12 or"
		elog "alternatively install virtual/perl-IO-Compress"
	}
	case " ${REPLACING_VERSIONS}" in
	' '[0-9][0-9]*|' '[3-9]*|' '2.[0-9][0-9]*|' '2.[7-9]*) :;;
	*)	FORCE_PRINT_ELOG="true";;
	esac
	readme.gentoo_pkg_postinst
}
