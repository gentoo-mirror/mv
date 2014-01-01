# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Firefox plugin: button to clear URL"
HOMEPAGE="http://addons.mozilla.org/firefox/addon/xclear/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/13078/${P}-sm+fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
