# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
inherit mv_mozextension
RESTRICT="mirror"

MY_P="${P/-/_}"
MY_P="${MY_P/-/_}"
DESCRIPTION="Edit the saved history of forms in mozilla"
HOMEPAGE="http://www.formhistory.blogspot.com/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/12021/${MY_P}-fx+sm.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
