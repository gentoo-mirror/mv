# Copyright 2010-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: edit the saved history of forms"
HOMEPAGE="http://www.formhistory.blogspot.com/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/file/769035/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults firefox seamonkey
