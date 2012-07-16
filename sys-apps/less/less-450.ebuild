# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils

DESCRIPTION="Excellent text file viewer, optionally with additional selection feature"
PATCHN="less-select"
PATCHV="2.2"
PATCHVER="436"
PATCHBALL="${PATCHN}-${PATCHV}.tar.gz"
HOMEPAGE="http://www.greenwoodsoftware.com/less/ https://github.com/vaeth/${PATCHN}"
SRC_URI="http://www.greenwoodsoftware.com/less/${P}.tar.gz
	less-select? ( http://github.com/vaeth/${PATCHN}/tarball/release-${PATCHV} -> ${PATCHBALL} )
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color"

LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+less-select pcre original-gentoo unicode"

DEPEND=">=app-misc/editor-wrapper-3
	>=sys-libs/ncurses-5.2
	pcre? ( dev-libs/libpcre )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${P}.tar.gz
	cp "${DISTDIR}"/code2color "${S}"/
	if use less-select
	then	unpack ${PATCHBALL}
		cd *"${PATCHN}"-*
		SELECTDIR=${PWD}
	fi
}

src_prepare() {
	if use less-select
	then	epatch "${SELECTDIR}/patches/less-${PATCHVER}-select.patch" || die
		"${SELECTDIR}"/after-patch || die "${SELECTDIR}/after-patch failed"
		sed -i -e 's|\([^a-zA-Z]\)/etc/less-select-key.bin|\1'"${EPREFIX%/}"'/etc/less/select-key.bin|g' \
			"${SELECTDIR}/bin/less-select" || die
	fi
	epatch "${FILESDIR}"/code2color.patch
	epatch_user
}

src_configure() {
	export ac_cv_lib_ncursesw_initscr=$(usex unicode)
	export ac_cv_lib_ncurses_initscr=$(usex !unicode)

	local regex="posix"
	use pcre && regex="pcre"

	econf \
		--with-regex=${regex} \
		--with-editor="${EPREFIX}"/usr/libexec/editor
}

src_compile() {
	default
	if use less-select
	then	./lesskey -o normal-key.bin "${SELECTDIR}/keys/less-normal-key.src" || die
		./lesskey -o select-key.bin "${SELECTDIR}/keys/less-select-key.src" || die
	fi
}

src_install() {
	local a
	default

	dobin code2color
	newbin "${FILESDIR}"/lesspipe.sh lesspipe
	dosym lesspipe /usr/bin/lesspipe.sh
	if use original-gentoo
	then	a="-R -M --shift 5"
	else	a="-sFRiMX --shift 5"
	fi
	printf '%s\n' 'LESSOPEN="|lesspipe.sh %s"' "LESS=\"${a}\"" >70less
	doenvd 70less

	dodoc NEWS README* "${FILESDIR}"/README.Gentoo

	if use less-select
	then	newdoc "${SELECTDIR}"/README README.less-select
		dobin "${SELECTDIR}/bin/"*
		insinto /etc/less
		# The first is required for less-select, the others are optional
		doins select-key.bin normal-key.bin
		newins "${SELECTDIR}/keys/less-select-key.src" select-key.src
		newins "${SELECTDIR}/keys/less-normal-key.src" normal-key.src
	fi
}

pkg_postinst() {
	einfo "lesspipe offers colorization options.  Run 'lesspipe -h' for info."
}
