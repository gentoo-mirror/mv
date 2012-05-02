# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit mv_mozextension
RESTRICT="mirror"

MY_P="${P/-/_}"
NAME="${MY_P}-fx.xpi"
DESCRIPTION="Firefox plugin: button to switch GUI locale"
HOMEPAGE="http://addons.mozilla.org/firefox/addon/locale-switcher/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/356/${NAME}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
