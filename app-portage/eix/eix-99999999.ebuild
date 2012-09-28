# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="git://git.berlios.de/${PN}"
EGIT_PROJECT="${PN}.git"
[ -n "${EVCS_OFFLINE}" ] || EGIT_REPACK=true
WANT_LIBTOOL=none
PLOCALES="de ru"
inherit autotools bash-completion-r1 eutils git-2 l10n multilib

DESCRIPTION="Search and query ebuilds, portage incl. local settings, ext. overlays, version changes, and more"
HOMEPAGE="http://eix.berlios.de"
SRC_URI=""
PROPERTIES="live"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="clang debug +dep doc nls optimization security strong-optimization sqlite tools zsh-completion"

RDEPEND="app-shells/push
	sqlite? ( >=dev-db/sqlite-3 )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	clang? ( sys-devel/clang )
	sys-devel/gettext"

pkg_setup() {
	if has_version "<${CATEGORY}/${PN}-0.25.3"; then
		local eixcache="${EROOT}/var/cache/${PN}"
		! test -f "${eixcache}" || rm -f -- "${eixcache}"
	fi
}

src_prepare() {
	epatch_user
	eautopoint
	eautoreconf
}

src_configure() {
	econf $(use_with sqlite) $(use_with doc extra-doc) \
		$(use_with zsh-completion) \
		$(use_enable nls) $(use_enable tools separate-tools) \
		$(use_enable security) $(use_enable optimization) \
		$(use_enable strong-optimization) $(use_enable debug debugging) \
		$(use_with prefix always-accept-keywords) \
		$(use_with dep dep-default) \
		$(use_with clang nongnu-cxx clang++) \
		--with-ebuild-sh-default="/usr/$(get_libdir)/portage/bin/ebuild.sh" \
		--with-portage-rootpath="${ROOTPATH}" \
		--with-eprefix-default="${EPREFIX}" \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html"
}

src_install() {
	default
	dobashcomp bash/eix
	keepdir "/var/cache/${PN}"
	fowners portage:portage "/var/cache/${PN}"
	fperms 775 "/var/cache/${PN}"
}

pkg_postinst() {
	# fowners in src_install doesn't work for owner/group portage:
	# merging changes this owner/group back to root.
	use prefix || chown portage:portage "${EROOT}var/cache/${PN}"
	local obs="${EROOT}var/cache/eix.previous"
	! test -f "${obs}" || ewarn "Found obsolete ${obs}, please remove it"
}
