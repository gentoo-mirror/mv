# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Mozilla plugin: Restrict active contents like java/javascript/flash"
HOMEPAGE="https://www.requestpolicy.com/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/9727/${P}-fx+sm.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
