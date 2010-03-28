# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="2"
inherit mozextension multilib
RESTRICT="mirror"

DESCRIPTION="Firefox plugin for long time cookies like ~/.adobe/Flash_Player/AssetCache/*/*"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/6623"
MY_P="${P/-/}"
MY_P="${MY_P%_alpha*}"
MY_P="${MY_P%_beta*}"
MY_P="${MY_P}-sm+fx"
FILENAME="${MY_P}.xpi"
SRC_URI="https://addons.mozilla.org/de/firefox/downloads/latest/6623/${FILENAME}"
case "${PV}" in
*_alpha*|*_beta*)
SRC_URI="https://addons.mozilla.org/de/firefox/downloads/file/76929/${FILENAME}?confirmed -> ${FILENAME}"
esac

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+flash"

RDEPEND="flash? ( www-plugins/adobe-flash )
|| (
	>=www-client/mozilla-firefox-bin-1.5.0.7
	>=www-client/mozilla-firefox-1.5.0.7
)"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${FILENAME}"
}

# xpi_install is buggy: The detection of emid fails
my_xpi_install() {
	local emid
	x="${1}"
	cd ${x}
	# determine id for extension
	emid=$(sed -n -e '/install-manifest/,$ { /<\?em:id>\?/!d; s/.*\([\"{].*[}\"]\).*/\1/; s/\"//g; p; q }' ${x}/install.rdf) \
		&& [ -n "${emid}" ] || die "failed to determine extension id"
	insinto "${MOZILLA_FIVE_HOME}"/extensions/${emid}
	doins -r "${x}"/* || die "failed to copy extension"
}

src_install() {
	declare MOZILLA_FIVE_HOME
	if has_version '>=www-client/mozilla-firefox-1.5.0.7'; then
		MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-firefox"
		my_xpi_install "${S}"/"${MY_P}"
	fi
	if has_version '>=www-client/mozilla-firefox-bin-1.5.0.7'; then
		MOZILLA_FIVE_HOME="/opt/firefox"
		my_xpi_install "${S}"/"${MY_P}"
	fi
}
