# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit mv_mozextension
RESTRICT="mirror"

MY_P="${PN//-/_}-${PV}"
DESCRIPTION="Mozilla plugin for changing mimetypes on the fly"
HOMEPAGE="http://www.spasche.net/openinbrowser/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/8207/${MY_P}-sm+fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
