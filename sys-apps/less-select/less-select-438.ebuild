# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

inherit eutils

DESCRIPTION="Excellent text file viewer, patched with additional selection feature"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
PATCHVER=436
SRC_URI="http://www.greenwoodsoftware.com/less/less-${PV}.tar.gz
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color
	http://www.mathematik.uni-wuerzburg.de/~vaeth/download/less-select-patch-${PATCHVER}.tar.gz"

LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="unicode dummy-less"

DEPEND=">=sys-libs/ncurses-5.2
	!dummy-less? ( !sys-apps/less )"

S="${WORKDIR}/less-${PV}"

MYSUBDIR="${S}/less-select-patch-${PATCHVER}"

src_unpack() {
	unpack "less-${PV}.tar.gz"
	cd "${S}"
	cp "${DISTDIR}"/code2color "${S}"/
	epatch "${FILESDIR}"/code2color.patch
	unpack "less-select-patch-${PATCHVER}.tar.gz"
	mv "${MYSUBDIR}/INSTALL" "${MYSUBDIR}/README.less-select"
	if test -e "${MYSUBDIR}/less-${PV}-select.patch"
	then	epatch "${MYSUBDIR}/less-${PV}-select.patch" || die "Patch less-${PV}-select failed"
	else	epatch "${MYSUBDIR}/less-${PATCHVER}-select.patch" || die "Patch less-${PATCHVER}-select failed"
	fi
	"${MYSUBDIR}"/after-patch || die "${MYSUBDIR}/after-patch failed"
}

yesno() { use $1 && echo yes || echo no ; }
src_compile() {
	export ac_cv_lib_ncursesw_initscr=$(yesno unicode)
	export ac_cv_lib_ncurses_initscr=$(yesno !unicode)
	econf || die
	emake || die
	./lesskey -o less-normal-key.bin "${MYSUBDIR}/less-normal-key.src" || die
	./lesskey -o less-select-key.bin "${MYSUBDIR}/less-select-key.src" || die
}

src_install() {
	emake install DESTDIR="${D}" || die

	dobin code2color || die "dobin"
	newbin "${FILESDIR}"/lesspipe.sh lesspipe || die "newbin"
	dosym lesspipe /usr/bin/lesspipe.sh
	echo 'LESSOPEN="|lesspipe.sh %s"
LESS="-sFR -iMX --shift 5"' > 70less
	doenvd 70less

	dodoc NEWS README* "${FILESDIR}"/README.Gentoo "${MYSUBDIR}"/README.less-select

	newbin "${MYSUBDIR}/less-select" less-select

	insinto /etc
	newins less-normal-key.bin lesskey.bin
	newins less-select-key.bin less-select-key.bin
	newins "${MYSUBDIR}/less-normal-key.src" lesskey.src
	newins "${MYSUBDIR}/less-select-key.src" less-select-key.src
}

pkg_postinst() {
	einfo "lesspipe offers colorization options.  Run 'lesspipe -h' for info."
}
