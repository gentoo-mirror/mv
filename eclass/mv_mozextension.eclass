# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

# @ECLASS: mv_mozextension.eclass
# @MAINTAINER:
# Martin Väth <martin@mvath.de>
# @BLURB: This eclass provides functions to install mozilla extensions
# @DESCRIPTION:
# The eclass is based on mozextension.eclass with many extensions.
# 1. It has some compatibility fixes in xpi_install/xpi_unpack.
# 2. A default src_unpack function is defined; set FILENAME to the archive name.
#    If FILENAME is unset or empty, the last part of the last SRC_URI is used.
# 3. Default functions for installation for all mozilla type browsers.

# @ECLASS-VARIABLE: MOZILLAS
# @DESCRIPTION:
# If this variables is set to the empty value, no default install functions
# are defined. Otherwise, the value of this variable should be
# "firefox icecat seamonkey" (default)
# or a subset of these.
# The eclass will then install the extension for all these mozillas,
# set corresponding dependencies and print corresponding messages.
: ${MOZILLAS="firefox icecat seamonkey"}

# @ECLASS-VARIABLE: MOZILLA_COMMON_EXTENSIONS
# @DESCRIPTION:
# If this variable has the special value "*", the extension is copied directly
# into the extension directory of the installed MOZILLA's.
# Otherwise, only symlinks are made in that directory, and the extension is
# installed only once into MOZILLA_COMMON_EXTENSIONS (a default directory is
# chosen if MOZILLA_COMMON_EXTENSIONS is empty).
# If this variable has the special value "?" (default), it acts like "*" or
# "" depending on whether MOZILLAS applies to more than 1 installed mozilla
# or not.
: ${MOZILLA_COMMON_EXTENSIONS="?"}

inherit multilib

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
	>=www-client/firefox-3.6
	>=www-client/firefox-bin-3.6";;
esac
case "${MOZILLAS}" in
*sea*)
	RDEPEND="${RDEPEND}
	>=www-client/seamonkey-2
	>=www-client/seamonkey-bin-2";;
esac
case "${MOZILLAS}" in
*ice*)
	RDEPEND="${RDEPEND}
	>=www-client/icecat-3.6";;
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

declare -a MV_MOZ_INS MV_MOZ_PKG MV_MOZ_DIR MV_MOZ_SYM

mv_mozextension_install () {
	local MOZILLA_EXTENSIONS_DIRECTORY
	MOZILLA_EXTENSIONS_DIRECTORY="${1}"
	MV_MOZ_INS=()
	xpi_install_dirs
}

mv_mozextension_calc () {
	local i
	case "${MOZILLAS}" in
		${1}) false;;
	esac && return
	i="$(best_version "${2}")" && [ -n "${i}" ] || return
	MV_MOZ_PKG+=("${i}")
	MV_MOZ_DIR+=("${3}")
}

mv_mozextension_src_install () {
	local MOZILLA_FIVE_HOME b d i j
	MV_MOZ_PKG=()
	MV_MOZ_DIR=()
	MV_MOZ_SYM=()
	b="/usr/$(get_libdir)/"
	mv_mozextension_calc "*fire*" "www-client/firefox" "${b}mozilla-firefox"
	mv_mozextension_calc "*fire*" "www-client/firefox-bin" "/opt/firefox"
	mv_mozextension_calc "*ice*" "www-client/icecat" "${b}icecat"
	mv_mozextension_calc "*sea*" "www-client/seamonkey" "${b}seamonkey"
	mv_mozextension_calc "*sea*" "www-client/seamonkey-bin" "/opt/seamonkey"
	[ ${#MV_MOZ_DIR[@]} -ne 0 ] || die "no supported mozilla is installed"
	d="${MOZILLA_COMMON_EXTENSIONS}"
	if [ "${d}" = "?" ]
	then	if [ ${#MV_MOZ_PKG[@]} -gt 1 ]
		then	d=""
		else	d="*"
		fi
	fi
	if [ "${d}" != "*" ]
	then	if [ -n "${d}" ]
		then	mv_mozextension_install "${d}"
		else	mv_mozextension_install "${b}mozilla/extensions"
		fi
		for i in "${MV_MOZ_DIR[@]}"
		do	for j in "${MV_MOZ_INS[@]}"
			do	d="${i}/extensions/${j##*/}"
				MV_MOZ_SYM+=("${d}")
				dosym "${EROOT%/}${j}" "${d}"
			done
		done
	else	for i in "${MV_MOZ_DIR[@]}"
		do	MOZILLA_FIVE_HOME="${i}"
			xpi_install_dirs
		done
	fi
}

mv_mozextension_pkg_postinst () {
	local i
	[ "${#MV_MOZ_PKG[@]}" -ge 1 ] || die "no supported mozilla is installed"
	elog "${CATEGORY}/${PN} has been installed for the following packages:"
	for i in ${MV_MOZ_PKG[@]}
	do	elog "	${i}"
	done
	elog
	elog "When you install/uninstall/reemerge some of: ${MOZILLAS}"
	elog "you might need to reemerge ${CATEGORY}/${PN}"
	b=:
	for i in "${MV_MOZ_SYM[@]}"
	do	test -L "${i}" || {
		eerror
		eerror "It is necessary to reemerge again ${CATEGORY}/${PN}"
		eerror "(a directory should be removed in the cleanup after the first emerge"
		eerror "in order to install a symlink of the same name in the second emerge.)"
		eerror
		break
	}
	done
}

if [ -n "${MOZILLAS}" ]
then	EXPORT_FUNCTIONS src_install pkg_postinst
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
	local d x

	# You must tell xpi_install which dir to use
	[ ${#} -ne 1 ] && die "${FUNCNAME} takes exactly one argument. Please specify the directory"

	x="${1}"
	# determine id for extension
	d="$(sed -n -e '/install-manifest/,$ { /em:id/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }' "${x}"/install.rdf)" \
		&& [ -n "${d}" ] || die "failed to determine extension id"
	if [ -n "${MOZILLA_EXTENSIONS_DIRECTORY}" ]
	then	d="${MOZILLA_EXTENSIONS_DIRECTORY}/${d}"
		MV_MOZ_INS+=("${d}")
	else	d="${MOZILLA_FIVE_HOME}/extensions/${d}"
	fi
	insinto "${d}"
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
