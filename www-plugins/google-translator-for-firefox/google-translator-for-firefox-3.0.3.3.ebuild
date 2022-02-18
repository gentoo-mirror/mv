# Copyright 2018-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: translate text or page with google translator"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/google-translator-for-firefox/
https://translatorforfirefox.blogspot.com/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/46308/google_translator_for_firefox-${PV}-fx.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults firefox seamonkey
