# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Let mozilla clear long time cookies like ~/.adobe/Flash_Player/AssetCache/*/*"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/6623"
MY_P="${P/-/}"
MY_P="${MY_P%_alpha*}"
MY_P="${MY_P%_beta*}"
MY_P="${MY_P}-sm+fx"
FILENAME="${MY_P}.xpi"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/6623/${FILENAME}"
case "${PV}" in
*_alpha*|*_beta*)
SRC_URI="https://addons.mozilla.org/de/firefox/downloads/file/76929/${FILENAME}?confirmed -> ${FILENAME}"
esac

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+flash"

ALL_DEPEND="flash? ( www-plugins/adobe-flash )"
RDEPEND="${RDEPEND}
${ALL_DEPEND}"
DEPEND="${DEPEND}
${ALL_DEPEND}"

