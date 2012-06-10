# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
DICT_PREFIX=""
inherit eutils stardict
RESTRICT="mirror"

DESCRIPTION="Stardict Dictionary for Dictd.org's Oxford Advanced Learner's Dictionary"
HOMEPAGE="http://stardict.sourceforge.net/Dictionaries_dictd-www.dict.org.php"

KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=""

src_prepare() {
	epatch_user
}
