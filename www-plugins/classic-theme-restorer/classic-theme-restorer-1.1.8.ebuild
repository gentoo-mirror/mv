# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
MV_MOZ_MOZILLAS="firefox"
inherit mv_mozextension
RESTRICT="mirror"

mPN="${PN//-/_}_customize_australis-${PV}"
DESCRIPTION="Firefox plugin: restore partially the functionality of non-broken firefox versions"
HOMEPAGE="https://addons.mozilla.org/de/firefox/addon/classicthemerestorer/"
SRC_URI=" https://addons.cdn.mozilla.net/storage/public-staging/472577/${mPN}-fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
