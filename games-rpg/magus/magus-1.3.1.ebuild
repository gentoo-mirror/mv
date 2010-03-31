# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="2"
inherit autotools
RESTRICT="mirror"

DESCRIPTION="A character generator for the popular German role playing game Midgard"
HOMEPAGE="http://midgard.berlios.de"
SRC_URI="ftp://ftp.berlios.de/pub/midgard/Source/magus-1.3.1.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="firefox seamonkey kde pdf postgres"

DEPENDCOMMON=">=dev-libs/libsigc++-2.0.1
	>=dev-cpp/gtkmm-2.4.0
	virtual/latex-base
	postgres? ( virtual/postgresql-server )
	!postgres? ( >=dev-db/sqlite-3 )"

DEPEND="${DEPENDCOMMON}
	media-gfx/pngcrush
	!games-rpg/magus-cvs
	!games-rpg/magus-live"

RDEPEND="${DEPENDCOMMON}
	firefox? ( || ( www-client/mozilla-firefox www-client/mozilla-firefox-bin ) )
	seamonkey? ( www-client/seamonkey )
	kde? ( || ( kde-base/konqueror kde-base/kdebase ) )
	pdf? ( app-text/acroread )"

src_sed() {
	local short file ori ignore remove
	ignore=false
	remove=false
	while case "${1}" in
		-f) remove=true;;
		-i) ignore=true;;
		*) false;;
	esac
	do
		shift
	done
	short="${1}"
	file="${S}/${short}"
	ori="${file}.ori"
	test -e "${ori}" && ${ignore} && ori="${file}.ori-1" && remove=true
	test -e "${ori}" && die "File ${ori} already exists"
	if ! test -e "${file}"
	then
		die "Expected file ${short} does not exist"
		return 0
	fi
	einfo "Patching ${short}"
	mv -- "${file}" "${ori}"
	shift
	sed "${@}" -- "${ori}" >"${file}"
	! ${ignore} && cmp -s -- "${ori}" "${file}" \
			&& ewarn "Unneeded patching of ${short}"
	${remove} && rm -- "${ori}"
	return 0
}

src_patch() {
	einfo
	einfo "Various patches:"
	einfo
	src_sed midgard/tools/translate/translate.cc -e "1i#include <cstdlib>"
	src_sed midgard/libmagus/MidgardBasicElement.cc -e "1i#include <cstdio>"
	src_sed ManuProC_Base/src/Makefile.am \
		-e "s/ \$(includedir)/ \$(DESTDIR)\$(includedir)/"
	grep "^LIB" midgard/libmagus/Makefile.am && \
		ewarn "Unneeded patching of midgard/libmagus/Makefile.am"
	src_sed midgard/libmagus/Makefile.am -e "2iLIBS=-lManuProC_Base"

	local browser="mozilla"
	use seamonkey && browser="seamonkey"
	use firefox && browser="firefox"
	use kde && browser="konqueror"
	[ "${browser}" = "mozilla" ] && return
	src_sed midgard/docs/BMod_Op.html -e "s#mozilla#${browser}#"
	src_sed midgard/libmagus/Magus_Optionen.cc -e "s#mozilla#${browser}#"
	src_sed midgard/midgard.glade -e "s#mozilla#${browser}#"
	src_sed midgard/src/table_optionen_glade.cc -e "s#mozilla#${browser}#"
}

my_cd() {
	cd -- "${S}/${1}" >/dev/null || die "cd ${1} failed"
}

my_autoreconf() {
	einfo
	einfo "eautoreconf ${1}:"
	einfo
	my_cd "${1}"
	export AT_M4DIR
	test -d macros && AT_M4DIR="macros" || AT_M4DIR=""
	eautoreconf
}

src_prepare() {
	src_patch
	local i
	for i in "${S}"/*
	do
		my_autoreconf "${i##*/}"
	done
}

my_conf() {
	einfo
	einfo "configuring ${1}"
	einfo
	my_cd "${1}"
	shift
	if [ -z "${COMMON_CONF}" ]
	then
		COMMON_CONF="$(use_enable !postgres sqlite)"
		COMMON_CONF="${COMMON_CONF} $(use_with postgres postgresdir /usr)"
		COMMON_CONF="${COMMON_CONF} --disable-static"
	fi
	econf ${COMMON_CONF} "${@}"
}

my_make() {
	einfo
	einfo "making ${*}"
	einfo
	my_cd "${1}"
	emake || die "emake in ${1} failed"
}

my_confmake() {
	# It is unfortunate that we must build here,
	# but some ./configure's require make in other directories_
	my_make "GtkmmAddons" "(needed for configuring ManuProC_Widget and midgard)"
	my_make "ManuProC_Base" "(needed for configuring ManuProC_Widget and midgard)"
	my_conf "ManuProC_Widgets"
	my_make "ManuProC_Widgets" "(needed for configuring midgard)"
	my_conf "midgard"
}

src_configure() {
	my_conf "ManuProC_Base"
	my_conf "GtkmmAddons"
	my_confmake
}

src_compile() {
	my_make "midgard"
}

my_install() {
	my_cd "${1}"
	emake DESTDIR="${D}" install || die "make install in ${1} failed"
}

src_install() {
	my_install "ManuProC_Base"
	my_install "midgard"
	find "${D}" -name "*.la" -type f -exec rm -v -- '{}' '+'

	insinto "/usr/share/magus"

	my_cd "midgard"

	doins -r docs
	#doins xml/*.xml src/*.png src/*.tex

	local MYICON MYRES
	for MYICON in pixmaps/desktop-icons/MAGUS-*.png
	do
		test -e "${MYICON}" || continue
		MYRES="${MYICON##*/MAGUS?}"
		MYRES="${MYRES%.png}"
		insinto "/usr/share/icons/hicolor/${MYRES}/apps"
		doins "${MYICON}"
	done
}

