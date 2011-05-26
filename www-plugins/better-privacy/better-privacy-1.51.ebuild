# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Let mozilla clear long time cookies like ~/.adobe/Flash_Player/AssetCache/*/*"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/6623"
MY_P="${P/-/}"
MY_P="${MY_P%_alpha*}"
MY_P="${MY_P%_beta*}"
MY_P="${MY_P}-fx+sm"
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

COMMON_DEPEND="flash? ( www-plugins/adobe-flash )"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

