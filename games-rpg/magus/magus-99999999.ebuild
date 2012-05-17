# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit eutils autotools flag-o-matic
RESTRICT="mirror"

case ${PV} in
9999*)
	LIVE_VERSION=:;;
*)
	LIVE_VERSION=false;;
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
IUSE="+acroread icecat konqueror postgres pngcrush seamonkey"

DEPENDCOMMON="dev-libs/libsigc++:2
	dev-cpp/gtkmm:2.4
	virtual/latex-base
	postgres? ( virtual/postgresql-server )
	!postgres? ( dev-db/sqlite:3 )
	|| ( media-libs/netpbm media-gfx/graphicsmagick media-gfx/imagemagick )"

DEPEND="${DEPENDCOMMON}
	sys-devel/gettext
	pngcrush? ( media-gfx/pngcrush )"

RDEPEND="${DEPENDCOMMON}
	!icecat? (
		!seamonkey? (
			!konqueror? (
			 || ( www-client/firefox www-client/firefox-bin )
			)
		)
	)
	icecat? ( www-client/icecat )
	seamonkey? ( www-client/seamonkey )
	konqueror? ( kde-base/konqueror )
	acroread? ( app-text/acroread )
	virtual/libintl"

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
	local short file ori ignore remove grep opt
	ignore=false
	remove=false
	grep=''
	OPTIND=1
	while getopts 'fig:' opt
	do	case ${opt} in
		f)	remove=:;;
		i)	ignore=:;;
		g)	grep=${OPTARG};;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	short=${1}
	file="${S}/${short}"
	ori="${file}.ori"
	test -e "${ori}" && ${ignore} && ori="${file}.ori-1" && remove=:
	test -e "${ori}" && die "File ${ori} already exists"
	if ! test -e "${file}"
	then	die "Expected file ${short} does not exist"
	fi
	einfo "Patching ${short}"
	[ -n "${grep}" ] && grep -q -- "${grep}" "${file}" \
		&& ewarn "Redundant patching of ${short}"
	mv -- "${file}" "${ori}"
	shift
	sed "${@}" -- "${ori}" >"${file}"
	! ${ignore} && cmp -s -- "${ori}" "${file}" \
			&& ewarn "Unneeded patching of ${short}"
	${remove} && rm -- "${ori}"
	return 0
}

set_browser() {
	einfo "Using browser ${browser}"
	[ "${browser}" = "mozilla" ] && return
	src_sed midgard/docs/BMod_Op.html -e "s#mozilla#${browser}#"
	src_sed midgard/libmagus/Magus_Optionen.cc -e "s#mozilla#${browser}#"
	src_sed midgard/midgard.glade -e "s#mozilla#${browser}#"
	src_sed midgard/src/table_optionen_glade.cc -e "s#mozilla#${browser}#"
}

src_patch() {
	local i
	einfo
	einfo "Various patches:"
	einfo
	grep "saebel.png" midgard/src/Makefile.am && \
		ewarn "Unneeded patching of midgard/src/Makefile.am"
	src_sed  midgard/src/Makefile.am \
		-e 's/drache.png/Money-gray.png saebel.png drache.png/'
	src_sed ManuProC_Widgets/configure.in \
		-e 's/^[ 	]*AM_GNU_GETTEXT_VERSION/AM_GNU_GETTEXT_VERSION/'
	src_sed -g 'AM_GNU_GETTEXT_VERSION' ManuProC_Base/configure.in \
		-e '/AC_SUBST(GETTEXT_PACKAGE)/iAM_GNU_GETTEXT_VERSION([0.17])'
#	src_cp ManuProC_Base/macros/petig.m4 ManuProC_Widgets/macros/petig.m4
	src_sed midgard/src/table_lernschema.cc \
		 '/case .*:$/{n;s/^[ 	]*\}/break;}/}'

	for i in icecat seamonkey konqueror
	do	if use "${i}"
		then	set_browser "${i}"
			return
		fi
	done
	set_browser "firefox"
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
	grep -q 'AM_GNU_GETTEXT' configure.in && eautopoint
	eautoreconf
}

src_prepare() {
	local i
	src_patch
	epatch_user
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
	filter-flags \
		-flto \
		-fwhole-program \
		-fuse-linker-plugin \
		-fvisibility-inlines-hidden
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
		myres=${myicon##*/MAGUS?}
		myres=${myres%.png}
		insinto "/usr/share/icons/hicolor/${myres}/apps"
		doins "${myicon}"
	done
}

