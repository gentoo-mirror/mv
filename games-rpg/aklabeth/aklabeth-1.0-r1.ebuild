# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DESCRIPTION="A remake of Richard C. Garriott's Ultima prequel"
HOMEPAGE="http://www.autismuk.freeserve.co.uk/"
SRC_URI="http://www.autismuk.freeserve.co.uk/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

DEPEND="media-libs/libsdl"

src_prepare() {
	eapply -p0 "${FILESDIR}"/${P}-gcc43.patch
	eapply_user
}

src_install() {
	dobin src/aklabeth
	dodoc AUTHORS README NEWS
}
