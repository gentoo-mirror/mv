# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
MV_MOZ_MOZILLAS="firefox"
inherit mv_mozextension
RESTRICT="mirror"

mPN="${PN}_for_firefox-${PV}"
DESCRIPTION="Firefox plugin: enable duckduckgo search engine"
HOMEPAGE="http://addons.mozilla.org/en-US/firefox/addon/duckduckgo-for-firefox/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/385621/${mPN}-fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
