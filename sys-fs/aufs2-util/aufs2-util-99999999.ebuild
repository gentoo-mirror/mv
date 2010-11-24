# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="3"

EGIT_REPO_URI="http://git.c3sl.ufpr.br/pub/scm/aufs/aufs2-util.git"
EGIT_PROJECT="aufs2-util"
# BRANCH/COMMIT will be overridden in pkg_setup (according to kernel version)
EGIT_BRANCH="aufs2.1"
EGIT_COMMIT="${EGIT_BRANCH}"
[ -n "${EGIT_OFFLINE:-${ESCM_OFFLINE}}" ] || EGIT_PRUNE=true

inherit git linux-info multilib

DESCRIPTION="Userspace tools for aufs2"
HOMEPAGE="http://aufs.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
# Since this is a live ebuild, we require ACCEPT_KEYWORDS='**'
#KEYWORDS="~amd64 ~x86"
KEYWORDS=""
IUSE=""
PROPERTIES="live"

RDEPEND=""
DEPEND="dev-vcs/git[curl]"

src_prepare() {
	local i l
	ln -s "${KERNEL_DIR}"/include local_kernel
	set -- local_kernel/linux/aufs*.h
	test -e "${1}" || {
		eerror "It seems you do not have installed aufs2 into your kernel tree."
		die "You might need to emerge =sys-fs/aufs2-99999999::mv"
	}
	l="s|/usr/lib|$(get_libdir)|"
	sed -i -e "1iCFLAGS += -I./local_kernel" -e "${l}" Makefile || \
		die "Patching Makefile failed"
	for i in lib*/Makefile
	do	test -e "${i}" || continue
		sed -i -e "1iCFLAGS += -I../local_kernel" -e "${l}" "${i}" || \
			die "Patching ${i} failed"
	done
}

src_install() {
	emake DESTDIR="${D}" install
}
