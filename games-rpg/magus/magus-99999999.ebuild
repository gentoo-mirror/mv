# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit autotools flag-o-matic
RESTRICT="mirror"

case "${PV}" in
9999*)
	LIVE_VERSION=:
;;
*)
	LIVE_VERSION=false
;;
esac

${LIVE_VERSION} && inherit monotone

DESCRIPTION="A character generator for the popular German role playing game Midgard"
HOMEPAGE="http://midgard.berlios.de"
SRC_URI="ftp://ftp.berlios.de/pub/midgard/Source/${P}.tar.bz2"
KEYWORDS="~amd64 ~x86"
if ${LIVE_VERSION}
then	PROPERTIES="live"
	SRC_URI=""
	EMTN_REPO_URI="petig-baender.dyndns.org"
	KEYWORDS=""
fi
LICENSE="GPL-2"
SLOT="0"
IUSE="+acroread firefox icecat konqueror postgres seamonkey"

DEPENDCOMMON=">=dev-libs/libsigc++-2.0.1
	>=dev-cpp/gtkmm-2.4.0
	>=sys-devel/gettext-0.17
	virtual/latex-base
	postgres? ( virtual/postgresql-server )
	!postgres? ( >=dev-db/sqlite-3 )"

DEPEND="${DEPENDCOMMON}
	media-gfx/pngcrush"

RDEPEND="${RDEPEND}
	${DEPENDCOMMON}
	firefox? ( || ( www-client/firefox www-client/firefox-bin ) )
	icecat? ( www-client/icecat )
	seamonkey? ( www-client/seamonkey )
	konqueror? ( kde-base/konqueror )
	acroread? ( app-text/acroread )"

REQUIRED_USE="^^ ( firefox icecat seamonkey konqueror )"

if ${LIVE_VERSION}
then
src_unpack() {
	monotone_fetch
	monotone_co "" "manuproc.berlios.de/ManuProC_Base"
	monotone_co "" "manuproc.berlios.de/GtkmmAddons"
	monotone_co "" "manuproc.berlios.de/ManuProC_Widgets"
	monotone_co "" "midgard.berlios.de/midgard"
	monotone_finish
}
fi

src_cp() {
	einfo "cp ${1} ${2}"
	test -f "${1}" || {
		ewarn "File ${1} does not exist"
		return 0
	}
	if ! test -e "${2}" || diff -q -- "${1}" "${2}" >/dev/null 2>&1
	then	ewarn "cp ${1} ${2} appears no longer necessary"
		return 0
	fi
	cp -- "${1}" "${2}"
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
	do	shift
	done
	short="${1}"
	file="${S}/${short}"
	ori="${file}.ori"
	test -e "${ori}" && ${ignore} && ori="${file}.ori-1" && remove=true
	test -e "${ori}" && die "File ${ori} already exists"
	if ! test -e "${file}"
	then	die "Expected file ${short} does not exist"
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
	local browser i
	einfo
	einfo "Various patches:"
	einfo
	grep "saebel.png" midgard/src/Makefile.am && \
		ewarn "Unneeded patching of midgard/src/Makefile.am"
	src_sed  midgard/src/Makefile.am \
		-e 's/drache.png/Money-gray.png saebel.png drache.png/'
	src_sed ManuProC_Widgets/configure.in \
		-e 's/^[ 	]*AM_GNU_GETTEXT_VERSION/AM_GNU_GETTEXT_VERSION/'
#	src_cp ManuProC_Base/macros/petig.m4 ManuProC_Widgets/macros/petig.m4

	for i in konqueror icecat seamonkey firefox mozilla
	do	use "${i}" && browser="${i}" && break
	done
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
	if grep -q 'AM_GNU_GETTEXT' configure.in
	then	einfo "Running autopoint --force"
		autopoint --force >/dev/null || die "autopoint failed"
	fi
	eautoreconf
}

src_prepare() {
	local i
	src_patch
	for i in "${S}"/*
	do	my_autoreconf "${i##*/}"
	done
}

my_conf() {
	einfo
	einfo "configuring ${1}"
	einfo
	my_cd "${1}"
	shift
	if [ -z "${COMMON_CONF}" ]
	then	COMMON_CONF="$(use_enable !postgres sqlite)"
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
	filter-flags -flto -fwhole-program
	my_conf "ManuProC_Base"
	my_conf "GtkmmAddons"
	my_confmake
}

src_compile() {
	my_make "midgard"
}

my_install() {
	my_cd "${1}"
	emake DESTDIR="${ED}" install || die "make install in ${1} failed"
}

src_install() {
	local myicon myres
	my_install "ManuProC_Base"
	my_install "ManuProC_Widgets"
	my_install "midgard"
	rm -rf -- "${ED}"/usr/include
	find "${ED}" -name "*.la" -type f -exec rm -v -- '{}' '+'

	insinto "/usr/share/magus"

	my_cd "midgard"

	doins -r docs
	#doins xml/*.xml src/*.png src/*.tex

	for myicon in pixmaps/desktop-icons/MAGUS-*.png
	do	test -e "${myicon}" || continue
		myres="${myicon##*/MAGUS?}"
		myres="${myres%.png}"
		insinto "/usr/share/icons/hicolor/${myres}/apps"
		doins "${myicon}"
	done
}

