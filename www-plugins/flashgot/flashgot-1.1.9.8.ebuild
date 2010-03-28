# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

inherit mozextension multilib
RESTRICT="mirror"

DESCRIPTION="Firefox plugin: download manager"
HOMEPAGE="http://flashgot.net/"
SRC_URI="http://software.informaction.com/data/releases/${P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="|| (
	>=www-client/mozilla-firefox-bin-1.5.0.7
	>=www-client/mozilla-firefox-1.5.0.7
)"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME
	if has_version '>=www-client/mozilla-firefox-1.5.0.7'; then
		MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-firefox"
		xpi_install "${S}"/"${P}"
	fi
	if has_version '>=www-client/mozilla-firefox-bin-1.5.0.7'; then
		MOZILLA_FIVE_HOME="/opt/firefox"
		xpi_install "${S}"/"${P}"
	fi
}
