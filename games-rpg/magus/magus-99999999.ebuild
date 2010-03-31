# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="2"
inherit autotools

DESCRIPTION="A character generator for the popular German role playing game Midgard"
HOMEPAGE="http://midgard.berlios.de"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="firefox seamonkey kde pdf postgres"
PROPERTIES="live"

DEPENDCOMMON=">=dev-libs/libsigc++-2.0.1
	>=dev-cpp/gtkmm-2.4.0
	virtual/latex-base
	postgres? ( virtual/postgresql-server )
	!postgres? ( >=dev-db/sqlite-3 )"

DEPEND="${DEPENDCOMMON}
	media-gfx/pngcrush
	dev-vcs/monotone
	!games-rpg/magus-cvs
	!games-rpg/magus-live"

RDEPEND="${DEPENDCOMMON}
	firefox? ( || ( www-client/mozilla-firefox www-client/mozilla-firefox-bin ) )
	seamonkey? ( www-client/seamonkey )
	kde? ( || ( kde-base/konqueror kde-base/kdebase ) )
	pdf? ( app-text/acroread )"

mtn_fetch() {
	if ! test -d "${MTN_TOP_DIR}"
	then
		addwrite /foobar
		addwrite /
		mkdir -p -- "/${MTN_TOP_DIR}"
		export SANDBOX_WRITE="${SANDBOX_WRITE//:\/foobar:\/}"
	fi
	cd -P -- "${MTN_TOP_DIR}" >/dev/null || die "cannot cd to ${MTN_TOP_DIR}"
	MTN_TOP_DIR="${PWD}"
	addwrite "${MTN_TOP_DIR}"

	if ! test -e "${MTN_DB}"
	then
		mtn -d "${MTN_DB}" db init || die "mtn init failed"
		mtn -d "${MTN_DB}" pull "petig-baender.dyndns.org" "*" || \
			die "mtn pull failed"
	else
		mtn -d "${MTN_DB}" pull || die "mtn pull failed"
	fi
}

mtn_co_module() {
	local p m r
	p="${1}"
	m="${1##*/}"
	shift
	if [ ${#} -gt 0 ]
	then
		[ "${1}" = '--' ] || m="${1}"
		shift
	fi
	if [ ${#} -eq 0 ]
	then
		r=`mtn -d "${MTN_DB}" automate heads "${p}" | tail -n1`
		set -- -r "${r}"
	fi
	test -d "${m}" && rm -rf -- "${m}"
	mtn -d "${MTN_DB}" -b "${p}" co "${@}" "${m}" || \
		die "mtn -d ${MTN_DB} -b ${p} co ${*} ${m} failed"
}

mtn_co() {
	einfo "Copying database ${MTN_DB_FULL} ..."
	test -d "${S}" || mkdir -p -- "${S}" || die "mkdir ${S} failed"
	cd -- "${S}" >/dev/null
	cp -p -- "${MTN_DB_FULL}" "${MTN_DB}"
	einfo "Checking out from temporary ${MTN_DB} ..."
	mtn_co_module "manuproc.berlios.de/ManuProC_Base"
	mtn_co_module "manuproc.berlios.de/GtkmmAddons"
	mtn_co_module "manuproc.berlios.de/ManuProC_Widgets"
	mtn_co_module "midgard.berlios.de/midgard"
	rm -- "${MTN_DB}" || die "cannot remove temporary ${MTN_DB}"
}

mtn_src_unpack() {
	: ${EMTN_OFFLINE:="${ESCM_OFFLINE}"}
	case "${EMTN_OFFLINE:-0}" in
		n*|N*|f*|F*|0)
			mtn_fetch || die "mtn fetch failed."
			;;
		*)	test -e "${MTN_DB_FULL}" || \
			die "Offline mode specified, but database ${MTN_DB_FULL} not found. Aborting."
			;;
	esac
}

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

mtn_unpack() {
	local MTN_TOP_DIR="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/mtn-src"
	local MTN_DB="magus.db"
	local MTN_DB_FULL="${MTN_TOP_DIR}/${MTN_DB}"
	mtn_src_unpack
	mtn_co "${MTN_DB}"
}

src_unpack() {
	mtn_unpack
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

