# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit eutils

DESCRIPTION="Excellent text file viewer, optionally with additional selection feature"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
PATCHVER=436
SRC_URI="http://www.greenwoodsoftware.com/less/${P}.tar.gz
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color
	less-select? ( http://www.mathematik.uni-wuerzburg.de/~vaeth/download/less-select-patch-${PATCHVER}.tar.gz )"

LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="+less-select original-gentoo unicode"

DEPEND=">=sys-libs/ncurses-5.2"

SELECTDIR="./less-select-patch-${PATCHVER}"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"
	cp "${DISTDIR}"/code2color "${S}"/
	if use less-select
	then	unpack "less-select-patch-${PATCHVER}.tar.gz"
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/code2color.patch
	if use less-select
	then	mv -- "${SELECTDIR}/INSTALL" "${SELECTDIR}/README.less-select"
		if test -e "${SELECTDIR}/less-${PV}-select.patch"
		then	epatch "${SELECTDIR}/less-${PV}-select.patch" || die "Patch less-${PV}-select failed"
		else	epatch "${SELECTDIR}/less-${PATCHVER}-select.patch" || die "Patch less-${PATCHVER}-select failed"
		fi
		"${SELECTDIR}"/after-patch || die "${SELECTDIR}/after-patch failed"
	fi
}

yesno() { use $1 && echo yes || echo no ; }
src_configure() {
	export ac_cv_lib_ncursesw_initscr=$(yesno unicode)
	export ac_cv_lib_ncurses_initscr=$(yesno !unicode)
	econf || die
}

src_compile() {
	default_src_compile
	if use less-select
	then	./lesskey -o less-normal-key.bin "${SELECTDIR}/less-normal-key.src" || die
		./lesskey -o less-select-key.bin "${SELECTDIR}/less-select-key.src" || die
	fi
}

src_install() {
	local a
	default_src_install

	dobin code2color || die "dobin"
	newbin "${FILESDIR}"/lesspipe.sh lesspipe || die "newbin"
	dosym lesspipe /usr/bin/lesspipe.sh
	newenvd "${FILESDIR}"/less.envd 70less

	dodoc NEWS README* "${FILESDIR}"/README.Gentoo

	if use original-gentoo
	then	a="-R -M --shift 5"
	else	a="-sFRiMX --shift 5"
	fi
	printf '%s\n' 'LESSOPEN="|lesspipe.sh %s"' "LESS=\"${a}\"" >70less
	doenv 70less

	if use less-select
	then	dodoc "${SELECTDIR}"/README.less-select
		newbin "${SELECTDIR}/less-select" less-select
		insinto /etc
		newins less-normal-key.bin lesskey.bin
		newins less-select-key.bin less-select-key.bin
		newins "${SELECTDIR}/less-normal-key.src" lesskey.src
		newins "${SELECTDIR}/less-select-key.src" less-select-key.src
	fi
}

pkg_postinst() {
	einfo "lesspipe offers colorization options.  Run 'lesspipe -h' for info."
}
