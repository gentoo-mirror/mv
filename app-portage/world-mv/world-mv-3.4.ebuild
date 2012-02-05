# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
RESTRICT="mirror"

mPN="${PN%-*}"
DESCRIPTION="Plugin for FETCHCOMMAND to help organize and cleanup your DISTDIR"
HOMEPAGE="https://github.com/vaeth/${mPN}"
SRC_URI="http://github.com/vaeth/${mPN}/tarball/release-${PV} -> ${mPN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"

RDEPEND=">=sys-apps/portage-2.2"

src_unpack() {
	default
	cd *"${mPN}"-*
	S="${PWD}"
}

src_prepare() {
	sed -i -e "s'\"\${EPREFIX}\"'\\'${EPREFIX}\\''" "${mPN}" || die
}

src_install() {
	dobin "${mPN}"
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins _"${mPN}"
	fi
}
