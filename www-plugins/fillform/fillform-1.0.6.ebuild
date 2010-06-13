# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
MOZILLAS="firefox icecat"
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Save/restore forms in firefox with Alt-Q/Alt-W"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/160849/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/160849/${P}-fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
