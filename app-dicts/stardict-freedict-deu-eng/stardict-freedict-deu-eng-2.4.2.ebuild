# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
FROM_LANG="German"
TO_LANG="English"
DICT_PREFIX="dictd_www.freedict.de_"
inherit eutils stardict
RESTRICT="mirror"

HOMEPAGE="http://stardict.sourceforge.net/Dictionaries_dictd-www.freedict.de.php"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	epatch_user
}
