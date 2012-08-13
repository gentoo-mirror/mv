# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
inherit eutils
DESCRIPTION="Directory of help-files (for run-help) for your current zsh"
HOMEPAGE="http://www.zsh.org/"
SRC_URI=""

LICENSE="ZSH"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="app-shells/zsh
	!!app-shells/zsh[run-help]"
DEPEND="${RDEPEND}
	dev-lang/perl
	sys-apps/man
	sys-apps/util-linux"
# We need util-linux for colcrt.
# Please let me know if you have an arch where "colcrt" (or at least "col")
# is provided by a different package.

src_unpack() {
	mkdir "${S}"
}

src_prepare() {
	local help i mystatus
	# We need GROFF_NO_SGR to produce "classical" formatting:
	export GROFF_NO_SGR=''
	export LANG=C
	unset MANPL LC_ALL
	[ -z "${LC_CTYPE}" ] && export LC_CTYPE=en_US.utf8
	help=''
	for i in /usr/share/zsh/*/Util/helpfiles
	do	test -r "${i}" && help="${i}"
	done
	[ -n "${help}" ] || die "Cannot find the helpfiles utility of your zsh"
	man zshbuiltins | colcrt - | perl "${help}"
	mystatus="${PIPESTATUS[*]}"
	case "${mystatus}" in
	*[![:space:]0]*)
		die "pipe man|colcrt|helpfiles failed: ${mystatus}";;
	esac
	test -e zmodload || {
		eerror "Not all required files were produced."
		eerror "This can be caused by a broken locale setting:"
		eerror "Try to set LC_CTYPE to a utf8 aware locale like en_US.utf8,"
		eerror "making sure that this locale is supported by your glibc."
		eerror "For compatibility reasons, this ebuild ignores LC_ALL."
		die "Failed to produce necessary files"
	}
	epatch_user
}

src_install() {
	insinto /usr/share/zsh/site-contrib/help
	doins *
}

pkg_postinst() {
	elog "In order to use ${CATEGORY}/${PN} add to your ~/.zshrc"
	elog "unalias run-help"
	elog "autoload -Uz run-help"
	elog "HELPDIR=/usr/share/zsh/site-contrib/help"
}
