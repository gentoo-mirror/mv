# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Video-downloadmanager as mozilla plugin"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/3006"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/3006/${P#*-}-fx+sm.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
