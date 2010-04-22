# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

inherit mozextension multilib
RESTRICT="mirror"

DESCRIPTION="Firefox plugin to modify style of certain web pages, in particular of gentoo forums"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/3006"
MY_P="${P#*-}-fx+sm"
FILENAME="${MY_P}.xpi"
SRC_URI="https://addons.mozilla.org/de/firefox/downloads/latest/3006/${FILENAME}"

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
	xpi_unpack "${FILENAME}"
}

src_install() {
	declare MOZILLA_FIVE_HOME
	if has_version '>=www-client/mozilla-firefox-1.5.0.7'; then
		MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-firefox"
		xpi_install "${S}"/"${MY_P}"
	fi
	if has_version '>=www-client/mozilla-firefox-bin-1.5.0.7'; then
		MOZILLA_FIVE_HOME="/opt/firefox"
		xpi_install "${S}"/"${MY_P}"
	fi
}
