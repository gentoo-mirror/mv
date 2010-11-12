# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"
inherit mv_mozextension
RESTRICT="mirror"

MY_P="${PN//-/_}-${PV}"
DESCRIPTION="Mozilla plugin for changing mimetypes on the fly"
HOMEPAGE="http://www.spasche.net/openinbrowser/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/8207/${MY_P}-fx+sm.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_postinst() {
	mv_mozextension_src_postinst
	elog
	elog "You will probably want to setup the \"Darker forum\" style."
	elog "The old version could be found at"
	elog "	http://jesgue.homelinux.org/other-files/dark-gentoo-forums.css"
	elog "but now it is easier to surf with javascript activated to"
	elog "	http://userstyles.org/users/8172"
	elog "Note that you have to temporarily disable noscript for that site."
}
