# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="A zshrc file initializing zsh specific interactive features"
HOMEPAGE="https://github.com/vaeth/zshrc-mv/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	epatch_user
}

src_install() {
	dodoc README
	insinto /etc/zsh
	doins zshrc
}

pkg_postinst() {
	local i
	for i in \
		'>=app-shells/auto-fu-zsh-0.0.1.13' \
		'app-shells/zsh-syntax-highlighting' \
		'app-shells/set_prompt' \
		'app-shells/termcolors-mv'
	do	has_version "${i}" || elog "It is recommended to install ${i}"
	done
}
