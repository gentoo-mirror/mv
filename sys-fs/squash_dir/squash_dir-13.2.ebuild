# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
WANT_LIBTOOL=none
AUTOTOOLS_IN_SOURCE_BUILD=true
inherit autotools autotools-utils eutils linux-info systemd vcs-snapshot

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="aufs overlayfs bundled-openrc-wrapper unionfs-fuse zsh-completion"

RDEPEND="sys-fs/squashfs-tools
	!bundled-openrc-wrapper? ( sys-apps/openrc-wrapper )
	!<app-shells/runtitle-2.3
	zsh-completion? ( app-shells/runtitle[zsh-completion] )
	!<sys-fs/unionfs-fuse-0.25
	unionfs-fuse? ( sys-fs/unionfs-fuse )"
DEPEND=">=sys-devel/autoconf-2.65"

src_prepare() {
	if [ -n "${EPREFIX}" ]
	then	sed -i \
		-e "s\"'[^']*/etc/conf[.]d/${PN}'\"'${EPREFIX}/etc/conf.d/${PN}'\"g" \
			"init.d/${PN}" || die
		sed -i \
		-e "s\"=/etc/\"=${EPREFIX}/etc/\"" \
		-e "s\"=/usr/\"=${EPREFIX}/usr/\"" \
			"systemd/${PN}@.service" || die
		sed -i \
		-e "s\":/usr/sbin:/sbin'\":${EPREFIX}/usr/sbin:${EPREFIX}/sbin:/usr/sbin:/sbin'\"" \
			"sbin/${PN}" || die
		sed -i \
		-e "s\"'/lib/rc/bin:\":'${EPREFIX}/lib/rc/bin:/lib/rc/bin:\"" \
			"sbin/openrc-wrapper" || die
	fi
	epatch_user
	eautoreconf
}

src_configure() {
	local order=
	use unionfs-fuse && order=unionfs-fuse
	use aufs && order=aufs
	use overlayfs && order=overlayfs
	local myeconfargs=(
		"$(use_with zsh-completion)"
		"$(use_enable bundled-openrc-wrapper openrc-wrapper)"
		${order:+"--with-first-order=${order}"}
	)
	systemd_to_myeconfargs
	autotools-utils_src_configure
}

linux_config_missing() {
	! linux_config_exists || ! linux_chkconfig_present "${1}"
}

pkg_postinst() {
	local fs=overlayfs
	use unionfs-fuse && fs=unionfs-fuse
	use aufs && fs=aufs
	use overlayfs && fs=overlayfs
	if linux_config_missing 'SQUASHFS'
	then	ewarn "To use ${PN} activate squashfs in your kernel"
	fi
	case ${fs} in
	overlayfs)
		if linux_config_missing 'OVERLAYFS_FS'
		then	ewarn "To use ${PN} activate overlayfs in your kernel."
			ewarn "Unless you use a patched kernel, apply e.g. top patches from some head of"
			ewarn "http://git.kernel.org/?p=linux/kernel/git/mszeredi/vfs.git;a=summary"
		fi;;
	aufs)
		if ! has_version sys-fs/aufs3 && ! has_version sys-fs/aufs2 && linux_config_missing 'AUFS_FS'
		then	ewarn "To use ${PN} activate aufs in your kernel. Use e.g. sys-fs/aufs*"
		fi;;
	esac
	local i ok=false
	for i in ${REPLACING_VERSIONS}
	do	case ${i} in
		[0-9].*|1[01].*|12.[0-6])	continue;;
		esac
		ok=:
		break
	done
	${ok} || elog "Please adopt ${EPREFIX}/etc/conf.d/${PN} to your needs"
	if ! has_version sys-fs/squashfs-tools[progress-redirect]
	then	elog "For better output of ${PN}, it is recommended to install"
		elog "sys-fs/squashfs-tools from the mv overlay with USE=progress-redirect"
	fi
	has_version app-shells/runtitle || elog \
		"Install app-shells/runtitle to let ${PN} update the status bar"
}
