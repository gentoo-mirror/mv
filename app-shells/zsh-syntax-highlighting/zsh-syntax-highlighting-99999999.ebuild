# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

case ${PV} in
99999999*)
	EGIT_REPO_URI="git://github.com/zsh-users/${PN}.git"
	inherit git-r3
	PROPERTIES="live"
	SRC_URI=""
	KEYWORDS="";;
*)
	RESTRICT="mirror"
	inherit vcs-snapshot
	SRC_URI="http://github.com/zsh-users/${PN}/tarball/${PV} -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86";;
esac

DESCRIPTION="Fish shell like syntax highlighting for zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-syntax-highlighting"

LICENSE="HPND"
SLOT="0"
IUSE=""

RDEPEND="app-shells/zsh"
DEPEND=""

src_prepare() {
	grep -q 'local .*cdpath_dir' >/dev/null 2>&1 || \
		sed -i -e '/for cdpath_dir/ilocal cdpath_dir' \
			-- "${S}/highlighters/main/main-highlighter.zsh" || die
	epatch_user
}

src_install() {
	dodoc *.md
	insinto /usr/share/zsh/site-contrib/${PN}
	doins *.zsh
	doins -r highlighters
}

pkg_postinst() {
	[ -n "${REPLACING_VERSIONS}" ] && return
	elog "In order to use ${CATEGORY}/${PN} add"
	elog ". /usr/share/zsh/site-contrib/${PN}/zsh-syntax-highlighting.zsh"
	elog "at the end of your ~/.zshrc"
	elog "For testing, you can also execute the above command in your zsh."
}
