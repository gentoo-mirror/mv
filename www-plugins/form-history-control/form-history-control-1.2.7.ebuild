# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
inherit mv_mozextension
RESTRICT="mirror"

MY_P="${P/-/_}"
MY_P="${MY_P/-/_}"
NAME="${MY_P}-fx+sm.xpi"
DESCRIPTION="Edit the saved history of forms in mozilla"
HOMEPAGE="http://www.formhistory.blogspot.com/"
SRC_URI="https://addons.mozilla.org/en-us/firefox/downloads/file/101293/${NAME}?src=version-history&confirmed&src=external-blog -> ${NAME}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""
