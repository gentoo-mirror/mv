# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils

DESCRIPTION="Provide support for /etc/portage/bashrc.d and /etc/portage/package.cflags"
HOMEPAGE="https://github.com/vaeth/portage-bashrc-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="!<dev-util/ccache-3.2"

src_prepare() {
	epatch_user
}

src_install() {
	insinto /etc/portage
	doins -r bashrc bashrc.d
	docompress /etc/portage/bashrc.d/README
}

pkg_postinst() {
	optfeature "improved mask handling" app-portage/eix
	! test -d /var/cache/gpo || \
		ewarn "Obsolete /var/cache/gpo found. Please remove"
}
