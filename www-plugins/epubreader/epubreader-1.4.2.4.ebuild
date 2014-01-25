# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Firefox plugin for ebook (.epub) files"
HOMEPAGE="http://addons.mozilla.org/de/firefox/addon/epubreader/"
SRC_URI="http://static.addons.mozilla.net/storage/public-staging/45281//${P}-sm+fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
