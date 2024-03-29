# Copyright 2010-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: restrict active contents like java/javascript/flash"
HOMEPAGE="http://noscript.net/"
SRC_URI="https://secure.informaction.com/download/releases/${P}.xpi
https://addons.cdn.mozilla.net/user-media/addons/722/noscript_security_suite-${PV}-an+fx.xpi -> ${P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults '>=firefox-59' seamonkey
