# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
DICT_PREFIX=""
inherit eutils stardict
RESTRICT="mirror"

DESCRIPTION="Stardict Dictionary for Dictd.org's Longman Dictionary of Contemporary English"
HOMEPAGE="http://stardict.sourceforge.net/Dictionaries_dictd-www.dict.org.php"

KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	epatch_user
}
