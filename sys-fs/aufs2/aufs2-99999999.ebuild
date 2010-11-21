# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"

EGIT_REPO_URI="http://git.c3sl.ufpr.br/pub/scm/aufs/aufs2-standalone.git"
EGIT_PROJECT="aufs2"
# BRANCH/COMMIT will be overridden in pkg_setup (according to kernel version)
EGIT_BRANCH="aufs2.1"
EGIT_COMMIT="${EGIT_BRANCH}"
[ -n "${EGIT_OFFLINE:-${ESCM_OFFLINE}}" ] || EGIT_PRUNE=true

inherit git linux-info eutils

DESCRIPTION="An entirely re-designed and re-implemented Unionfs."
HOMEPAGE="http://aufs.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
# Since this is a live ebuild with unstable versions in portage we require
# that the user unmasks this ebuild with ACCEPT_KEYWORDS='**'
#KEYWORDS="~amd64 ~x86"
KEYWORDS=""
IUSE="doc kernel-patch"
PROPERTIES="live"

RDEPEND=""
DEPEND="dev-vcs/git[curl]"

declare -a my_patchlist

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

	if [ -n "${AUFS2BRANCH}" ]
	then	EGIT_BRANCH="${AUFS2BRANCH}"
	else	[ -n "${KV_PATCH}" ] && EGIT_BRANCH="aufs2.1-${KV_PATCH}"
	fi
	elog
	elog "Using aufs2 branch: ${EGIT_BRANCH}"
	elog "If this guess for the branch is wrong, set AUFS2BRANCH."
	elog "For example, to use the aufs2.1 branch for kernel version 2.6.36, use:"
	elog "	AUFS2BRANCH=aufs2.1-36 emerge -1 aufs2"
	elog "For the most current kernel it might be necessary to use one of"
	elog "	AUFS2BRANCH=aufs2.1 emerge -1 aufs2"
	elog "	AUFS2BRANCH=aufs2 emerge -1 aufs2"
	msg=''
	[ -n "${ESCM_OFFLINE}" ] && msg="${msg} ESCM_OFFLINE=''"
	[ -n "${EGIT_OFFLINE}" ] && msg="${msg} EGIT_OFFLINE=''"
	if [ -n "${msg}" ]
	then
		elog "Note that it might be necessary in addition to fetch the newest aufs2:"
		elog "Set ${msg# } and be sure to be online during emerge."
	fi
	elog
	EGIT_COMMIT="${EGIT_BRANCH}"

	use kernel-patch || return 0
	(
		cd -- "${KV_DIR}" >/dev/null 2>&1 && \
		for i in aufs*.patch aufs*.diff
		do	test -f "${i}" || continue
			if patch -R -p1 --dry-run --force <"${i}" >/dev/null
			then
				einfo "Applying kernel patch ${i} reversely"
				patch -R -p1 --force --no-backup-if-mismatch \
					<"${i}" >/dev/null || {
					eerror "Reverse applying kernel patch ${i} failed."
					eerror "Since dry run succeeded this is probably a problem with write permissions."
					die "With USE=-kernel-patch you avoid automatic patching attempts."
				}
			else
				ewarn "Kernel patch ${i} cannot be reverse applied - skipping."
			fi
		done
	)
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
	if use doc && test -e Documentation
	then
		cp -pPR -- Documentation "${dk}"
		rm -- "${dk}/${i}"
	fi
	my_patchlist=()
	for i in *.patch *.diff
	do	test -f "${i}" || continue
		my_patchlist+=("${i}")
		cp -pPR -- "${i}" "${dk}"
	done
}

pkg_postinst() {
	[ "${#my_patchlist[@]}" -eq 0 ] && {
		cd -- "${KV_DIR}" >/dev/null 2>&1 && for i in *.patch *.diff
		do	test -f "${i}" && my_patchlist+=("${i}")
		done
	}
	if use kernel-patch
	then
		cd -- "${KV_DIR}" >/dev/null 2>&1 || die "cannot cd to ${KV_DIR}"
		use kernel-patch && epatch "${my_patchlist[@]}"
		elog "Your kernel has been patched. Cleanup and recompile it, selecting"
	else
		elog "You will have to apply the following patch to your kernel:"
		elog "	cd ${KV_DIR} && cat ${my_patchlist[*]} | patch -p1 --no-backup-if-mismatch"
		elog "Then cleanup and recompile your kernel, selecting"
	fi
	elog "	Filesystems/Miscellaneous Filesystems/aufs"
	elog "in the configuration phase."
}
