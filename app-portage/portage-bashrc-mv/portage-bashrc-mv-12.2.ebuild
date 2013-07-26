# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="Provide support for /etc/portage/bashrc.d and /etc/portage/package.cflags"
HOMEPAGE="https://github.com/vaeth/portage-bashrc-mv/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	epatch_user
}

src_install() {
	insinto /etc/portage
	doins -r bashrc bashrc.d
	docompress /etc/portage/bashrc.d/README
}

pkg_postinst() {
	has_version app-portage/eix || \
		elog "Installing app-portage/eix will improve mask handling"
	! test -d /var/cache/gpo || \
		ewarn 'Obsolete /var/cache/gpo found. Please remove'
}
