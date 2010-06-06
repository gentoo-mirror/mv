# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Firefox plugin to modify style of certain web pages, in particular of gentoo forums"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/3006"
SRC_URI="https://addons.mozilla.org/de/firefox/downloads/latest/3006/${P#*-}-fx+sm.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
