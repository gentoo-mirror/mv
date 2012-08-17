# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils

case ${PV} in
99999999*)
	EGIT_REPO_URI="git://github.com/zsh-users/${PN}.git"
	[ -n "${EVCS_OFFLINE}" ] || EGIT_REPACK=true
	inherit git-2
	PROPERTIES="live"
	SRC_URI=""
	KEYWORDS="";;
*)
	inherit vcs-snapshot
	SRC_URI="http://github.com/zsh-users/${PN}/tarball/${PV} -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86";;
esac

DESCRIPTION="Fish shell like syntax highlighting for zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-syntax-highlighting"

LICENSE="as-is"
SLOT="0"
IUSE=""

RDEPEND="app-shells/zsh"
DEPEND=""

src_prepare() {
	epatch_user
}

src_install() {
	dodoc *.md
	insinto /usr/share/zsh/site-contrib
	doins *.zsh
	doins -r highlighters
}

pkg_postinst() {
	elog "In order to use ${CATEGORY}/${PN} add"
	elog ". /usr/share/zsh/site-contrib/zsh-syntax-highlighting.zsh"
	elog "at the end of your ~/.zshrc"
	elog "For testing, you can also execute the above command in your zsh."
}
