# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
MV_MOZ_MOZILLAS="firefox icecat"
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Firefox plugin: button to clear URL"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/13078/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/13078/${P}-fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
