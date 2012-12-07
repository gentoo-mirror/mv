# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit mv_mozextension
RESTRICT="mirror"

mPN="${PN}_for_firefox-${PV}"
DESCRIPTION="Firefox plugin: enable duckduckgo search engine"
HOMEPAGE="http://addons.mozilla.org/firefox/addon/xclear/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/file/179120/${mPN}-fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
