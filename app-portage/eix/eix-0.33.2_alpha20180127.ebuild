# Copyright 2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
WANT_LIBTOOL=none
AUTOTOOLS_AUTO_DEPEND=no
MESON_AUTO_DEPEND=no
inherit autotools bash-completion-r1 meson tmpfiles toolchain-funcs

case ${PV} in
99999999*)
	EGIT_REPO_URI="https://github.com/vaeth/${PN}.git"
	inherit git-r3
	SRC_URI=""
	PROPERTIES="live";;
*)
	RESTRICT="mirror"
	EGIT_COMMIT="e72ba76919f9bbe2a6c5e097436c035d35c54fa8"
	SRC_URI="https://github.com/vaeth/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
esac

DESCRIPTION="Search and query ebuilds"
HOMEPAGE="https://github.com/vaeth/eix/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
PLOCALES="de ru"
IUSE="debug +dep doc"
for i in ${PLOCALES}; do
	IUSE+=" l10n_${i}"
done
IUSE+=" +meson nls optimization +required-use security strong-optimization strong-security sqlite swap-remote tools"

BOTHDEPEND="nls? ( virtual/libintl )
	sqlite? ( >=dev-db/sqlite-3:= )"
RDEPEND="${BOTHDEPEND}
	>=app-shells/push-2.0-r2
	>=app-shells/quoter-3.0-r2"
DEPEND="${BOTHDEPEND}
	meson? (
		>=dev-util/meson-0.41.0
		>=dev-util/ninja-1.7.2
		strong-optimization? ( >=sys-devel/gcc-config-1.9.1 )
	)
	!meson? ( ${AUTOTOOLS_DEPEND} )
	>=sys-devel/gettext-0.19.6"

pkg_setup() {
	# remove stale cache file to prevent collisions
	local old_cache="${EROOT}var/cache/${PN}"
	test -f "${old_cache}" && rm -f -- "${old_cache}"
}

src_prepare() {
	sed -i -e "s'/'${EPREFIX}/'" -- "${S}"/tmpfiles.d/eix.conf || die
	default
	use meson || {
		eautopoint
		eautoreconf
	}
}

src_configure() {
	local i
	export LINGUAS=
	for i in ${PLOCALES}; do
		use l10n_${i} && LINGUAS+=${LINGUAS:+ }${i}
	done
	if use meson; then
		local emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${P}"
		-Dhtmldir="${EPREFIX}/usr/share/doc/${P}/html"
		$(meson_use sqlite)
		$(meson_use doc extra-doc)
		$(meson_use nls)
		$(meson_use tools separate-tools)
		$(meson_use security)
		$(meson_use optimization)
		$(meson_use strong-security)
		$(meson_use strong-optimization)
		$(meson_use debug debugging)
		$(meson_use swap-remote)
		$(meson_use prefix always-accept-keywords)
		$(meson_use dep dep-default)
		$(meson_use required-use required-use-default)
		-Dzsh-completion="${EPREFIX}/usr/share/zsh/site-functions"
		-Dportage-rootpath="${ROOTPATH}"
		-Deprefix-default="${EPREFIX}"
		)
		meson_src_configure
	else
		local myconf=(
		$(use_with sqlite)
		$(use_with doc extra-doc)
		$(use_enable nls)
		$(use_enable tools separate-tools)
		$(use_enable security)
		$(use_enable optimization)
		$(use_enable strong-security)
		$(use_enable strong-optimization)
		$(use_enable debug debugging)
		$(use_enable swap-remote)
		$(use_with prefix always-accept-keywords)
		$(use_with dep dep-default)
		$(use_with required-use required-use-default)
		--with-zsh-completion
		--with-portage-rootpath="${ROOTPATH}"
		--with-eprefix-default="${EPREFIX}"
		)
		econf "${myconf[@]}"
	fi
}

src_compile() {
	if use meson; then
		meson_src_compile
	else
		default
	fi
}

src_test() {
	if use meson; then
		meson_src_test
	else
		default
	fi
}

src_install() {
	if use meson; then
		meson_src_install
	else
		default
	fi
	dobashcomp bash/eix
	dotmpfiles tmpfiles.d/eix.conf
}

pkg_postinst() {
	local obs="${EROOT}var/cache/eix.previous"
	if test -f "${obs}"; then
		ewarn "Found obsolete ${obs}, please remove it"
	fi
	tmpfiles_process eix.conf
}

pkg_postrm() {
	if [ -z "${REPLACED_BY_VERSION}" ]; then
		rm -rf -- "${EROOT}var/cache/${PN}"
	fi
}
