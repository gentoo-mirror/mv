# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $
#
# mv_mozextention.eclass: installing firefox extensions and language packs
#
# This is mozextension.eclass from the portage tree with the following changes:
#
# 1. Some compatibility fixes in xpi_install/xpi_unpack.
# 2. A default src_unpack function is defined; set FILENAME to the archive name.
#    If FILENAME is unset or empty, the last part of the last SRC_URI is used.
# 3. Default functions for installation for all browsers.
#    If you want only installation for some browser, define
#    MOZILLAS="firefox seamonkey icecat" (or to a subset thereof)
#    before inheriting the eclass.
#    If you define MOZILLA="" before inheriting the eclass,
#    no default functions get defined.

: ${MOZILLAS="firefox seamonkey icecat"}

[ -n "${MOZILLAS}" ] && inherit multilib

case "${MOZILLAS}" in
''|icecat)
	RDEPEND=""
	RDEPEND_END="";;
*)
	RDEPEND="|| ("
	RDEPEND_END="
)";;
esac
case "${MOZILLAS}" in
*fire*)
	RDEPEND="${RDEPEND}
	>=www-client/mozilla-firefox-1.5
	>=www-client/firefox-bin-1.5";;
esac
case "${MOZILLAS}" in
*sea*)
	RDEPEND="${RDEPEND}
	>=www-client/seamonkey-1.1
	>=www-client/seamonkey-bin-1.1";;
esac
case "${MOZILLAS}" in
*ice*)
	RDEPEND="${RDEPEND}
	>=www-client/icecat-3.5";;
esac
RDEPEND="${RDEPEND}${RDEPEND_END}"

DEPEND="app-arch/unzip"
[ -n "${RDEPEND}" ] && DEPEND="${DEPEND}
${RDEPEND}"

mv_mozextension_src_unpack () {
	local i
	if [ -z "${FILENAME}" ]
	then	for i in ${SRC_URI}
		do	FILENAME="${i##*/}"
		done
	fi
	xpi_unpack "${FILENAME}"
}

EXPORT_FUNCTIONS src_unpack

if [ -n "${MOZILLAS}" ]
then

mv_mozextension_src_install () {
	local MOZILLA_FIVE_HOME
	INST_MOZILLAS=""
	case "${MOZILLAS}" in
	*fire*)
		if has_version '>=www-client/mozilla-firefox-1.5'
		then	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-firefox"
			xpi_install_dirs
			INST_MOZILLAS="${INST_MOZILLAS} $(best_version www-client/mozilla-firefox)"
		fi
		if has_version '>=www-client/firefox-bin-1.5'
		then	MOZILLA_FIVE_HOME="/opt/firefox"
			xpi_install_dirs
			INST_MOZILLAS="${INST_MOZILLAS} $(best_version www-client/firefox-bin)"
		fi;;
	esac
	case "${MOZILLAS}" in
	*sea*)
		if has_version '>=www-client/seamonkey-1.1'
		then	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/seamonkey"
			xpi_install_dirs
			INST_MOZILLAS="${INST_MOZILLAS} $(best_version www-client/seamonkey)"
		fi
		if has_version '>=www-client/seamonkey-bin-1.1'
		then	MOZILLA_FIVE_HOME="/opt/seamonkey"
			xpi_install_dirs
			INST_MOZILLAS="${INST_MOZILLAS} $(best_version www-client/seamonkey-bin)"
		fi;;
	esac
	case "${MOZILLAS}" in
	*ice*)
		if has_version '>=www-client/icecat-3.5'
		then	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/icecat"
			xpi_install_dirs
			INST_MOZILLAS="${INST_MOZILLAS} $(best_version www-client/icecat)"
		fi;;
	esac
}

mv_mozextension_pkg_postinst () {
	local i
	elog "${CATEGORY}/${PN} has been installed for the following packages:"
	for i in ${INST_MOZILLAS}
	do	elog "	${i}"
	done
	elog
	elog "After installing other mozilla ebuilds, if you want to use it with them,"
	elog "reemerge ${CATEGORY}/${PN}"
}

EXPORT_FUNCTIONS src_install pkg_postinst

fi

xpi_unpack () {
	local xpi srcdir

	# Not gonna use ${A} as we are looking for a specific option being passed to function
	# You must specify which xpi to use
	[ ${#} -eq 0 ] && die \
		"Nothing passed to the ${FUNCNAME} command. Please pass which xpi to unpack"

	for xpi
	do	einfo "Unpacking ${xpi} to ${WORKDIR}"
		xpiname="${xpi%.*}"
		xpiname="${xpiname##*/}"

		case "${xpi}" in
			./*|/*)
				srcdir=''
				;;
			*)
				srcdir="${DISTDIR}/"
				;;
		esac

		test -s "${srcdir}${xpi}" ||  die "${xpi} does not exist"

		case "${xpi##*.}" in
			ZIP|zip|jar|xpi)
				mkdir -- "${WORKDIR}/${xpiname}" && \
					cd -- "${WORKDIR}/${xpiname}" && \
					unzip -qo -- "${srcdir}${xpi}" \
						|| die "failed to unpack ${xpi}"
				;;
			*)
				einfo "unpack ${xpi}: file format not recognized. Ignoring."
				;;
		esac
	done
}

xpi_install () {
	local emid x

	# You must tell xpi_install which dir to use
	[ ${#} -ne 1 ] && die "${FUNCNAME} takes exactly one argument. Please specify the directory"

	x="${1}"
	cd -- "${x}"
	# determine id for extension
	emid="$(sed -n -e '/install-manifest/,$ { /em:id/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }' "${x}"/install.rdf)" \
		&& [ -n "${emid}" ] || die "failed to determine extension id"
	insinto "${MOZILLA_FIVE_HOME}/extensions/${emid}"
	doins -r "${x}"/* || die "failed to copy extension"
}

# This function is called by mv_mozextension_src_install
# and should be overridden if the paths do not match:
# It just should call xpi_install with the correct argument(s)
xpi_install_dirs () {
	local d
	for d in "${WORKDIR}"/*
	do	[ -n "${d}" ] && test -d "${d}" && xpi_install "${d}"
	done
}
