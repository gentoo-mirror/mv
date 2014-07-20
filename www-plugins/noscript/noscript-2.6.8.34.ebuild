# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Mozilla plugin: Restrict active contents like java/javascript/flash"
HOMEPAGE="http://noscript.net/"
SRC_URI="https://secure.informaction.com/download/releases/${P}.xpi
https://addons.cdn.mozilla.net/storage/public-staging/722/noscript_security_suite-${PV}-fn+sm+fx.xpi -> ${P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# NOTES:
# can also be used for Flock, MidBrowser, eMusic, Toolkit, Songbird, Fennec
