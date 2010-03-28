# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="1"
inherit mozextension multilib
RESTRICT="mirror"

DESCRIPTION="Firefox plugin to modify style of certain web pages, in particular of gentoo forums"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/2108"
MY_P="${P}-fx+tb+sm"
FILENAME="${MY_P}.xpi"
SRC_URI="https://addons.mozilla.org/de/firefox/downloads/latest/2108/${FILENAME}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

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

src_postinstall() {
	einfo "You will probably want to setup the \"Darker forum\" style."
	einfo "The old version could be found at"
	einfo "	http://jesgue.homelinux.org/other-files/dark-gentoo-forums.css"
	einfo "but now it is easier to serve with javascript activated to"
	einfo "	http://userstyles.org/users/8172"
	einfo "Note that you have to temporarily disable noscript for that site."
}
