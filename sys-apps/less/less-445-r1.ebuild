# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit eutils

DESCRIPTION="Excellent text file viewer, optionally with additional selection feature"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
PATCHVER="436"
SRC_URI="http://www.greenwoodsoftware.com/less/${P}.tar.gz
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color
	less-select? ( http://www.mathematik.uni-wuerzburg.de/~vaeth/download/less-select-patch-${PATCHVER}.tar.gz )"

LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="+less-select pcre original-gentoo unicode"

RDEPEND=">=app-misc/editor-wrapper-3
	>=sys-libs/ncurses-5.2
	pcre? ( dev-libs/libpcre )"
DEPEND="${RDEPEND}"

SELECTDIR="${WORKDIR}/less-select-patch-${PATCHVER}"

src_unpack() {
	unpack ${P}.tar.gz
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
		sed -i -e 's|\([^a-zA-Z]\)/etc/less-select-key.bin|\1'"${EPREFIX%/}"'/etc/less/select-key.bin|g' \
			"${SELECTDIR}/less-select"
	fi
}

src_configure() {
	export ac_cv_lib_ncursesw_initscr=$(usex unicode)
	export ac_cv_lib_ncurses_initscr=$(usex !unicode)

	local regex="posix"
	use pcre && regex="pcre"

	econf \
		--with-regex=${regex} \
		--with-editor=/usr/libexec/editor
}

src_compile() {
	default
	if use less-select
	then	./lesskey -o less-normal-key.bin "${SELECTDIR}/less-normal-key.src" || die
		./lesskey -o less-select-key.bin "${SELECTDIR}/less-select-key.src" || die
	fi
}

src_install() {
	local a
	default

	dobin code2color || die "dobin"
	newbin "${FILESDIR}"/lesspipe.sh lesspipe || die "newbin"
	dosym lesspipe /usr/bin/lesspipe.sh
	if use original-gentoo
	then	a="-R -M --shift 5"
	else	a="-sFRiMX --shift 5"
	fi
	printf '%s\n' 'LESSOPEN="|lesspipe.sh %s"' "LESS=\"${a}\"" >70less
	doenvd 70less

	dodoc NEWS README* "${FILESDIR}"/README.Gentoo

	if use less-select
	then	dodoc "${SELECTDIR}"/README.less-select
		newbin "${SELECTDIR}/less-select" less-select
		insinto /etc/less
		# The first is required for less-select, the others are optional
		newins less-select-key.bin select-key.bin
		newins less-normal-key.bin normal-key.bin
		newins "${SELECTDIR}/less-select-key.src" select-key.src
		newins "${SELECTDIR}/less-normal-key.src" normal-key.src
	fi
}

pkg_postinst() {
	einfo "lesspipe offers colorization options.  Run 'lesspipe -h' for info."
}
