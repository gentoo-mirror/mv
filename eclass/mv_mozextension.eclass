# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

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

# @ECLASS-VARIABLE: MV_MOZ_MOZILLAS
# @DESCRIPTION:
# If this variables is set to the empty value, no default install functions
# are defined. Otherwise, the value of this variable should be
# "firefox seamonkey" (default)
# or a subset of these.
# The eclass will then install the extension for all these mozillas,
# set corresponding dependencies and print corresponding messages.
: ${MV_MOZ_MOZILLAS=firefox seamonkey}

# @ECLASS-VARIABLE: MV_MOZ_EXTDIR
# @DESCRIPTION:
# If this variable has the special value "*", the extension is copied directly
# into the extension directory of the installed MOZILLA's.
# Otherwise, only symlinks are made in that directory, and the extension is
# installed only once into MV_MOZ_EXTDIR (a default directory is
# chosen if MV_MOZ_EXTDIR is empty).
# If this variable has the special value "?" (default), it acts like "*" or
# "" depending on whether MV_MOZ_MOZILLAS applies to more than 1 installed
# mozilla or not.
: ${MV_MOZ_EXTDIR=?}

inherit eutils multilib

RDEPEND='|| ('
case ${MV_MOZ_MOZILLAS} in
*fire*)
	RDEPEND="${RDEPEND}
	>=www-client/firefox-3.6
	>=www-client/firefox-bin-3.6"
esac
case ${MV_MOZ_MOZILLAS} in
*sea*)
	RDEPEND="${RDEPEND}
	>=www-client/seamonkey-2
	>=www-client/seamonkey-bin-2"
esac
RDEPEND=${RDEPEND}'
)'

DEPEND='app-arch/unzip'
[ -n "${RDEPEND}" ] && DEPEND="${DEPEND}
${RDEPEND}"

[ "${MV_MOZ_EXTDIR}" = '*' ] || IUSE='copy-extensions symlink-extensions'

mv_mozextension_src_unpack() {
	local i
	if [ -z "${FILENAME}" ]
	then	for i in ${SRC_URI}
		do	FILENAME=${i##*/}
		done
	fi
	xpi_unpack "${FILENAME}"
}

mv_mozextension_src_prepare() {
	epatch_user
}

EXPORT_FUNCTIONS src_unpack src_prepare

declare -a MV_MOZ_INS MV_MOZ_PKG MV_MOZ_CPY MV_MOZ_DIR

mv_mozextension_install() {
	local MOZILLA_EXTENSIONS_DIRECTORY
	MOZILLA_EXTENSIONS_DIRECTORY=${1}
	MV_MOZ_INS=()
	xpi_install_dirs
}

mv_mozextension_calc() {
	local v
	case ${MV_MOZ_MOZILLAS} in
	${1})	false;;
	esac && return
	v=`best_version "${2}"` && [ -n "${v}" ] || return
	MV_MOZ_PKG+=("${v}")
	MV_MOZ_DIR+=("${3}")
}

mv_mozextension_src_install() {
	local b d e i j k l s
	MV_MOZ_PKG=()
	MV_MOZ_DIR=()
	b="${EPREFIX%/}/usr/`get_libdir`/"
	e="${EPREFIX%/}/opt/"
	mv_mozextension_calc '*fire*' 'www-client/firefox' "${b}firefox"
	mv_mozextension_calc '*fire*' 'www-client/firefox-bin' "${e}firefox"
	mv_mozextension_calc '*sea*' 'www-client/seamonkey' "${b}seamonkey"
	mv_mozextension_calc '*sea*' 'www-client/seamonkey-bin' "${e}seamonkey"
	[ ${#MV_MOZ_DIR[@]} -ne 0 ] || die 'no supported mozilla is installed'
	d=${MV_MOZ_EXTDIR}
	if [ "${d}" = '?' ]
	then	if [ ${#MV_MOZ_PKG[@]} -gt 1 ]
		then	d=''
		else	d='*'
		fi
	fi
	MV_MOZ_SYM=()
	MV_MOZ_LNK=false
	if [ "${d}" = '*' ] || ! use symlink-extensions
	then	MV_MOZ_CPY=:
	else	MV_MOZ_CPY=false
		if [ -n "${d}" ]
		then	mv_mozextension_install "${d}"
		else	mv_mozextension_install "${b}mozilla/extensions"
		fi
	fi
	use copy-extensions || MV_MOZ_LNK=:
	for i in "${MV_MOZ_DIR[@]}"
	do	j="${i}/extensions"
		${MV_MOZ_CPY} && mv_mozextension_install "${j}"
		for k in "${MV_MOZ_INS[@]}"
		do	l="${j}/${k##*/}"
			MV_MOZ_SYM+=("${l}")
			${MV_MOZ_CPY} || dosym "${ROOT%/}${k}" "${l}"
		done
	done
}

mv_mozextension_pkg_preinst() {
	local i j
	einfo 'checking for switching between dirs and symlinks'
	for i in "${MV_MOZ_SYM[@]}"
	do	j=${ROOT%/}${i}
# There are two forms of installation:
# (1) symlink mozilla-dir/extensions/X -> $MOZILLA_EXTENSIONS_DIRECTORY/X
# (2) data in mozilla-dir/extensions/X
# Since we might switch between (1) and (2), we must take caution, since
# in general portage cannot merge into the live directory properly:
		if ${MV_MOZ_CPY}
		then	test -L "${j}" && {
# We switched from (1) to (2). If this happened, portage would
# actually merge the data of (2) into $MOZILLA_EXTENSIONS_DIRECTORY/X,
# since this is where the symlink from (1) points to.
# Hence, we have to remove this symlink in advance, in this case.
			rm -v -- "${j}"
		}
		else	test -d "${j}" && ! test -L "${j}" && {
# We switched from (2) to (1). If this happened, portage cannot
# merge the symlink to the live system, since this can only happen once
# the directory mozilla-dir/extensions/X is removed.
# We could remove this directory here.
# However, removing a directory is a dangerous thing, and so
# we prefer to tell the user only that he has to reemerge the package.
			eerror
			eerror "It is necessary to reemerge again ${CATEGORY}/${PN}"
			eerror '(a directory should be removed in the cleanup after the first emerge'
			eerror 'in order to install a symlink of the same name in the second emerge.)'
			eerror
			break
		}
		fi
	done
}

mv_mozextension_pkg_postinst() {
	local i
	[ "${#MV_MOZ_PKG[@]}" -ge 1 ] || die 'no supported mozilla is installed'
	elog "${CATEGORY}/${PN} has been installed for the following packages:"
	for i in ${MV_MOZ_PKG[@]}
	do	elog "	${i}"
	done
	elog "When you install/uninstall/reemerge some of: ${MV_MOZ_MOZILLAS}"
	elog "you might need to reemerge ${CATEGORY}/${PN}"
	${MV_MOZ_CPY} || {
		elog
		elog 'The extension was installed using symlinks. This saves space but may require'
		elog 'to remove ~/.mozilla/*/*/extensions.ini for each browser restart.'
	}
}

if [ -n "${MV_MOZ_MOZILLAS}" ]
then	EXPORT_FUNCTIONS src_install pkg_preinst pkg_postinst
fi

xpi_unpack() {
	local xpi srcdir

	# Not gonna use ${A} as we are looking for a specific option being passed to function
	# You must specify which xpi to use
	[ ${#} -eq 0 ] && die \
		"Nothing passed to the ${FUNCNAME} command. Please pass which xpi to unpack"

	test -d "${S}" || mkdir "${S}"
	for xpi
	do	einfo "Unpacking ${xpi} to ${S}"
		xpiname=${xpi%.*}
		xpiname=${xpiname##*/}

		case ${xpi} in
		./*|/*)
			srcdir='';;
		*)
			srcdir="${DISTDIR}/";;
		esac

		test -s "${srcdir}${xpi}" ||  die "${xpi} does not exist"

		case ${xpi##*.} in
		ZIP|zip|jar|xpi)
			mkdir -- "${S}/${xpiname}" && \
				cd -- "${S}/${xpiname}" && \
				unzip -qo -- "${srcdir}${xpi}" \
					|| die "failed to unpack ${xpi}"
			chmod -R a+rX,u+w,go-w -- "${S}/${xpiname}"
		;;
		*)
			einfo "unpack ${xpi}: file format not recognized. Ignoring."
		;;
		esac
	done
}

xpi_install() {
	local d x

	# You must tell xpi_install which dir to use
	[ ${#} -ne 1 ] && die "${FUNCNAME} takes exactly one argument. Please specify the directory"

	x=${1}
	# determine id for extension
	d='{ /\<\(em:\)*id\>/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }'
	d=`sed -n -e '/install-manifest/,$ '"${d}" "${x}"/install.rdf` \
		&& [ -n "${d}" ] || die 'failed to determine extension id'
	if [ -n "${MOZILLA_EXTENSIONS_DIRECTORY}" ]
	then	d="${MOZILLA_EXTENSIONS_DIRECTORY}/${d}"
		MV_MOZ_INS+=("${d}")
	else	d="${MOZILLA_FIVE_HOME}/extensions/${d}"
	fi
	test -d "${D}${d}" || dodir "${d}" || die "failed to create ${d}"
	${MV_MOZ_LNK} && cp -RPl -- "${x}"/* "${D}${d}" || {
		${MV_MOZ_LNK} && \
			ewarn 'Failed to hardlink extension. Falling back to USE=copy-extensions'
		insinto "${d}" && doins -r "${x}"/*
	} || {
		${MV_MOZ_LNK} && \
			die 'failed to copy extension. Please retry emerging with USE=copy-extensions'
		die 'failed to copy extension'
	}
}

# This function is called by mv_mozextension_src_install
# and should be overridden if the paths do not match:
# It just should call xpi_install with the correct argument(s)
xpi_install_dirs() {
	local d
	for d in "${S}"/*
	do	[ -n "${d}" ] && test -d "${d}" && xpi_install "${d}"
	done
}
