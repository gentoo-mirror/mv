# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
WANT_LIBTOOL=none
inherit eutils autotools vcs-snapshot

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="readonly +title zsh-completion"

RDEPEND="sys-fs/squashfs-tools
	title? ( >=app-shells/runtitle-2.3[zsh-completion?] )
	!readonly? ( || (
		sys-fs/aufs
		sys-fs/aufs3
		sys-fs/aufs2
		sys-fs/unionfs-fuse
		sys-fs/funionfs
		sys-fs/unionfs
	) )"
DEPEND=">=sys-devel/autoconf-2.65"

src_prepare() {
	epatch_user
	eautoreconf
}

src_configure() {
	econf --docdir="${EPREFIX}/usr/share/doc/${PF}" \
		"$(use_with zsh-completion)"
}

check_for_obsolete() {
	local a
	a="/etc/mtab.lock"
	if test -p '/etc/mtab' && test -e "${a}"
	then	ewarn
		ewarn "${a} is probably left from a previous install and now obsolete."
		ewarn "You probably want to remove it."
		ewarn
	fi
	a="${EPREFIX}/etc/portage/env/sys-fs/squashfs-tools"
	test -e "${a}" && grep -q "squash_dir's hack" "${a}" || return 0
	ewarn "You probably had installed ${PN} with USE=hack-squash-utils"
	ewarn "${a} is left from this."
	ewarn "This file is now obsolete."
	ewarn "It is recommended to remove it and to install instead"
	ewarn "sys-fs/squashfs-tools from the mv overlay with USE=progress-redirect"
	return 1
}

pkg_postinst() {
	if check_for_obsolete && \
		! has_version sys-fs/squashfs-tools[progress-redirect]
	then	ewarn "For better output of ${PN}, it is recommended to install"
		ewarn "sys-fs/squashfs-tools from the mv overlay with USE=progress-redirect"
	fi
	if has_version "<sys-fs/unionfs-fuse-0.25_alpha"
	then	ewarn "It is recommended to use >=unionfs-fuse-0.25_alpha"
		ewarn "Otherwise, if you use squash_dir with unionfs-fuse for the portage tree, put"
		ewarn "PORTAGE_RSYNC_EXTRA_OPTS=\"\${PORTAGE_RSYNC_EXTRA_OPTS} --exclude=/.unionfs\""
		ewarn "into your /etc/make.conf"
	fi
	:
}

pkg_postrm() {
	check_for_obsolete
	:
}
