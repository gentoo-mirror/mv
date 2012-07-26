# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
EGIT_REPO_URI="http://git.c3sl.ufpr.br/pub/scm/aufs/aufs2-standalone.git"
EGIT_PROJECT="aufs2.git"
# BRANCH/COMMIT will be overridden in pkg_setup (according to kernel version)
EGIT_BRANCH="aufs2.2"
EGIT_COMMIT=${EGIT_BRANCH}
EGIT_HAS_SUBMODULES=true
[ -n "${EVCS_OFFLINE}" ] || EGIT_REPACK=true
inherit eutils git-2 linux-info eutils

DESCRIPTION="An entirely re-designed and re-implemented Unionfs"
HOMEPAGE="http://aufs.sourceforge.net/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
# Since this is a live ebuild with unstable versions in portage we require
# that the user unmasks this ebuild with ACCEPT_KEYWORDS='**'
#KEYWORDS="~amd64 ~x86"
KEYWORDS=""
IUSE="kernel-patch all-patches"
PROPERTIES="live"

RDEPEND=""
DEPEND="dev-vcs/git[curl]"

declare -a my_patchlist

fill_my_patchlist() {
	local i
	my_patchlist=()
	for i
	do	case ${i} in
		*.patch|*.diff)	! test -f "${i}" || my_patchlist+=("${i}");;
		esac
	done
}

apply_my_patch() {
	local r
	r=
	if [ ${#} -gt 1 ]
	then	shift
		r='-R'
	fi
	patch ${r} -p1 --dry-run --force <"${1}" >/dev/null || return
	einfo "Applying kernel patch ${1}${r:+ reversely}"
	patch ${r} -p1 --force --no-backup-if-mismatch <"${1}" >/dev/null || {
		eerror "applying kernel patch ${1}${r:+ reversely} failed."
		eerror "Since dry run succeeded this is probably a problem with write permissions."
		die "With USE=-kernel-patch you avoid automatic patching attempts."
	}
}

apply_my_patchlist() {
	local r i
	r=
	if [ ${#} -gt 0 ]
	then	shift
		r='-R'
	fi
	set --
	for i in "${my_patchlist[@]}"
	do	if use all-patches || case ${i} in
		aufs*)	:;;
		*)	false;;
		esac
		then	apply_my_patch ${r} "${i}" || set -- "${@}" "${i}"
		else	einfo "Kernel patch ${i} - skipping as all-patches is not set"
		fi
	done
	for i
	do	apply_my_patch ${r} "${i}" || \
		ewarn "Kernel patch ${i} cannot be${r:+ reverse} applied - skipping."
	done
}

pkg_setup() {
	local msg
	linux-info_pkg_setup

	# kernel version check
	if kernel_is lt 2 6 26
	then
		eerror "${PN} is being developed and tested on linux-2.6.26 and later."
		eerror "Make sure you have a proper kernel version!"
		die "Wrong kernel version"
	fi

	if [ -n "${AUFSBRANCH}" ]
	then	EGIT_BRANCH="${AUFSBRANCH}"
	else	if kernel_is lt 3 0
		then	[ -n "${KV_PATCH}" ] && EGIT_BRANCH="aufs2.2-${KV_PATCH}"
		else	[ -n "${KV_MINOR}" ] && EGIT_BRANCH="aufs2.2-${KV_MAJOR}.${KV_MINOR}"
		fi
	fi
	elog
	elog "Using aufs branch: ${EGIT_BRANCH}"
	elog "If this guess for the branch is wrong, set AUFSBRANCH."
	elog "For example, to use the aufs2.2 branch for kernel version 3.0, use:"
	elog "	AUFSBRANCH=aufs2.2-3.0 emerge -1 aufs"
	elog "To use the aufs2.1 branch for kernel version 2.6.39 use:"
	elog "	AUFSBRANCH=aufs2.1-39 emerge -1 aufs"
	msg=
	if [ -n "${msg}" ]
	then
		elog "Note that it might be necessary in addition to fetch the newest aufs:"
		elog "Set ${msg# } and be sure to be online during emerge."
	fi
	elog
	EGIT_COMMIT=${EGIT_BRANCH}

	use kernel-patch || return 0
	(
		set --
		cd -- "${KV_DIR}" >/dev/null 2>&1 && \
		fill_my_patchlist *.patch *.diff && apply_my_patchlist -R
	)
}

src_prepare() {
	local i j w v newest all
	epatch_user
	all="2.2.0  2.2.1  2.2.2  2.2.2.r1"
	newest=${all##* }
	v=
	for i in ${GRSECURITYPATCHVER-+}
	do	case ${i} in
		'+')	j=${newest};;
		'*')	j=${all};;
		*)	w=:
			for j in ${all}
			do	[ "${i}" = "${j}" ] && w=false && continue
			done
			if ${w}
			then	warn "GRSECURITYPATCHVER contains bad version ${i}"
			else	j=${i}
			fi;;
		esac
		v="${v} ${j}"
	done
	v=${v# }
	elog
	elog "Using GRSECURITYPATCHVER: ${v}"
	elog "If you want other patches, set GRSECURITYPATCHVER to some or more of:"
	elog "${all}  +"
	elog "The special value + means the newest version (${newest}) and is default."
	elog "The special value * means all versions."
	elog
	for i in ${v}
	do	j="grsecurity-${i}.patch"
		cp -p -- "${FILESDIR}/${j}" "aufs-${j}" || die "copying ${j} failed"
	done
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	local i k dk
	i="Documentation/filesystems/aufs/aufs.5"
	test -e "${i}" && doman "${i}"
	k="$(readlink -f -- "${KV_DIR}")" && [ -n "${k}" ] || k="${KV_DIR}"
	dk="${D}/${k}"
	dodir "${k}/fs/aufs"
	cp -pPR -- fs/aufs/* "${dk}/fs/aufs"
	cp -pPR -- include "${dk}"
	find "${dk}"/include -name Kbuild -type f -exec rm -v -- '{}' ';'
	fill_my_patchlist *.patch *.diff
	cp -pPR -- "${my_patchlist[@]}" "${dk}"
}

pkg_postinst() {
	[ "${#my_patchlist[@]}" -eq 0 ] && {
		cd -- "${KV_DIR}" >/dev/null 2>&1 && fill_my_patchlist *.patch *.diff
	}
	if use kernel-patch
	then	cd -- "${KV_DIR}" >/dev/null 2>&1 || die "cannot cd to ${KV_DIR}"
		apply_my_patchlist
		elog "Your kernel has been patched. Cleanup and recompile it, selecting"
	else	elog "You will have to apply the following patch to your kernel:"
		elog "	cd ${KV_DIR} && cat ${my_patchlist[*]} | patch -p1 --no-backup-if-mismatch"
		elog "Then cleanup and recompile your kernel, selecting"
	fi
	elog "	Filesystems/Miscellaneous Filesystems/aufs"
	elog "in the configuration phase."
}
