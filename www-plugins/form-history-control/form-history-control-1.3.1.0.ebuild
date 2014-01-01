# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit mv_mozextension
RESTRICT="mirror"

MY_P="${P/-/_}"
MY_P="${MY_P/-/_}"
NAME="${MY_P}-fx+sm.xpi"
DESCRIPTION="Edit the saved history of forms in mozilla"
HOMEPAGE="http://www.formhistory.blogspot.com/"
SRC_URI="http://addons.cdn.mozilla.net/storage/public-staging/12021/${NAME}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
