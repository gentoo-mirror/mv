# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
MV_MOZ_MOZILLAS="firefox icecat"
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Save/restore forms in firefox with Alt-W/Alt-Q"
HOMEPAGE="http://addons.mozilla.org/firefox/addon/fillforms/"
SRC_URI="http://addons.mozilla.org/firefox/downloads/file/117083/${P}-fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
