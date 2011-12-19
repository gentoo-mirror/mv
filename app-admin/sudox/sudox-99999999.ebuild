# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"

EGIT_REPO_URI="git://github.com/vaeth/${PN}.git"
[ -n "${EVCS_OFFLINE}" ] || EGIT_REPACK=true
inherit git-2

DESCRIPTION="sudox is a wrapper for sudo which can pass X authority data and deal with screen and tmux"
HOMEPAGE="https://github.com/vaeth/${PN}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"
PROPERTIES="live"

src_install() {
	dobin sudox
	if use zsh-completion
	then	insinto ${EPREFIX%/}/usr/share/zsh/site-functions
			doins _sudox
	fi
}
