# Copyright 2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: force https for all websites of a provided list"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/https-everywhere/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/229918/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults firefox seamonkey
