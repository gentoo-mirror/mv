# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit mv_mozextension
RESTRICT="mirror"

DESCRIPTION="Mozilla plugin to modify style of certain web pages (e.g. Gentoo forums)"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/stylish/"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/addons/2108/${P}-sm+tb+fx.xpi"

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
