# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Mozilla plugin: Increases privacy and security by giving you control over cross-site requests"
HOMEPAGE="https://www.requestpolicy.com/"
SRC_URI="https://addons.cdn.mozilla.net/storage/public-staging/9727/${P}-sm+fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
