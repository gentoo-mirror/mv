# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
FROM_LANG="French"
TO_LANG="Vietnamese"
DESCRIPTION=""
inherit stardict
HOMEPAGE="https://sourceforge.net/projects/ovdp/"
SRC_URI="mirror://gentoo/PhapViet47K.zip"
KEYWORDS="amd64 ~arm64 x86"
IUSE=""
DEPEND="app-arch/unzip"
S=${WORKDIR}/PhapViet
