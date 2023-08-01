# Copyright 2011-2023 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="Provide support for /etc/portage/bashrc.d and /etc/portage/package.cflags"
HOMEPAGE="https://github.com/vaeth/portage-bashrc-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="+ccache +cflags +remove-la +title"

# the ccache script would run without dev-util/ccache but would be pointless:
RDEPEND="ccache? ( >=dev-util/ccache-3.2 )"

# The flags script would run without app-portage/eix, but package.cflags
# parsing would be much slower (and is almost not tested):
RDEPEND=${RDEPEND}" cflags? ( app-portage/eix )"

# The title script would do nothing without these packages:
RDEPEND=${RDEPEND}" title? (
	>=app-portage/portage-utils-0.80_pre20190605
	app-shells/runtitle
)"

src_install() {
	dodoc AUTHORS NEWS README.md
	exeinto "/usr/share/doc/${PF}"
	doexe fix-portage-2.2.15
	docompress -x "/usr/share/doc/${PF}/fix-portage-2.2.15"
	insinto /etc/portage
	doins -r bashrc
	insinto /etc/portage/bashrc.d
	doins bashrc.d/[a-zA-Z]*
	docompress /etc/portage/bashrc.d/README
	! use ccache || doins bashrc.d/*ccache*
	! use cflags || doins bashrc.d/*flag*
	doins bashrc.d/*locale*purge*
	! use remove-la || doins bashrc.d/*remove*la*
	! use title || doins bashrc.d/*title*
}

pkg_postinst() {
	case " ${REPLACING_VERSIONS}" in
	*' '[0-9].*|*' '1[0-2].*)
		ewarn "Remember to run /usr/share/doc/${PF}/fix-portage-2.2.15"
		ewarn "as the first command after upgrading to >=portage-2.2.15"
		ewarn "See NEWS for details";;
	esac
	! test -d /var/cache/gpo || \
		ewarn "Obsolete /var/cache/gpo found. Please remove"
}
