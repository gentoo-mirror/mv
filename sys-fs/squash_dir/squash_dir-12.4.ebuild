# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
WANT_LIBTOOL=none
inherit autotools eutils linux-info vcs-snapshot

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="aufs overlayfs +title unionfs-fuse zsh-completion"

RDEPEND="sys-fs/squashfs-tools
	!<sys-fs/unionfs-fuse-0.25
	title? ( >=app-shells/runtitle-2.3[zsh-completion?] )
	unionfs-fuse? ( sys-fs/unionfs-fuse )"
DEPEND=">=sys-devel/autoconf-2.65"

src_prepare() {
	epatch_user
	eautoreconf
}

src_configure() {
	local order=
	use unionfs-fuse && order=unionfs-fuse
	use aufs && order=aufs
	use overlayfs && order=overlayfs
	econf --docdir="${EPREFIX}/usr/share/doc/${PF}" \
		"$(use_with zsh-completion)" ${order:+"--with-first-order=${order}"}
}

pkg_postinst() {
	local CONFIG_CHECK fs=overlayfs sep=:
	use unionfs-fuse && fs=unionfs-fuse
	use aufs && fs=aufs
	use overlayfs && fs=overlayfs
	CONFIG_CHECK="~SQUASHFS"
	case ${fs} in
	overlayfs)
		CONFIG_CHECK="${CONFIG_CHECK} ~OVERLAYFS_FS"
		elog "To use ${PN} activate overlayfs in your kernel."
		elog "Unless you use a patched kernel, apply e.g. top patches from some head of"
		elog "http://git.kernel.org/?p=linux/kernel/git/mszeredi/vfs.git;a=summary"
		sep=elog;;
	aufs)
		if ! has_version sys-fs/aufs3 && ! has_version sys-fs/aufs2
		then	CONFIG_CHECK="${CONFIG_CHECK} ~AUFS_FS"
			elog "To use ${PN} activate aufs in your kernel. Use e.g. sys-fs/aufs*"
			sep=elog
		fi;;
	esac
	check_extra_config
	if ! has_version sys-fs/squashfs-tools[progress-redirect]
	then	${sep}
		elog "For better output of ${PN}, it is recommended to install"
		elog "sys-fs/squashfs-tools from the mv overlay with USE=progress-redirect"
	fi
}
