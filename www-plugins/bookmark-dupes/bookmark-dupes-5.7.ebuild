# Copyright 2017-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: remove duplicate bookmarks/empty folders/descriptions"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/bookmark-dupes/
https://github.com/vaeth/bookmarkdupes/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/870263/${PN//-/_}-${PV}-an+fx-linux.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults firefox seamonkey
