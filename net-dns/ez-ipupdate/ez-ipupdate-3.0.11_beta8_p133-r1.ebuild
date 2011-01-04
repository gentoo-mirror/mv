# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

EAPI="4"
inherit eutils versionator autotools
RESTRICT="mirror"

BASE_VER="$(get_version_component_range 1-4)"
PATCH_VER="$(get_version_component_range 5-)"

MY_PV="${BASE_VER/_beta/b}"
S="${WORKDIR}/${PN}-${MY_PV}"

if [ "${PATCH_VER:3:4}" != "0" ]
then	PATCH_VERSION="${PATCH_VER:1:2}.${PATCH_VER:3:4}"
else	PATCH_VERSION="${PATCH_VER:1:2}"
fi

DESCRIPTION="Dynamic DNS client for lots of dynamic dns services"
HOMEPAGE="http://ez-ipupdate.com/"
SRC_URI="mirror://debian/pool/main/e/ez-ipupdate/${PN}_${MY_PV}.orig.tar.gz
	mirror://debian/pool/main/e/ez-ipupdate/${PN}_${MY_PV}-${PATCH_VERSION}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

src_prepare() {
	epatch "${WORKDIR}/${PN}_${MY_PV}-${PATCH_VERSION}.diff"
	epatch "${FILESDIR}/${PN}-3.0.11_beta8-dnsexit.diff"
	epatch "${FILESDIR}/${PN}-3.0.11_beta8-3322.diff"
	epatch "${FILESDIR}/${PN}-linux.diff"

	EPATCH_SOURCE="${S}/debian/patches" \
		EPATCH_SUFFIX="diff" \
		EPATCH_FORCE="yes" \
		EPATCH_MULTI_MSG="Applying Debian patches ..." \
		epatch

	eautoreconf

	# comment out obsolete options
	sed -i -e "s:^\(run-as-user.*\):#\1:g" \
		-e "s:^\(cache-file.*\):#\1:g" ex*conf

	# make 'missing' executable (bug #103480)
	chmod +x missing
}

src_configure() {
	econf --bindir=/usr/sbin || die "econf failed"
}

src_install() {
	default_src_install
	newinitd "${FILESDIR}/ez-ipupdate.initd" ez-ipupdate
	keepdir /etc/ez-ipupdate /var/cache/ez-ipupdate

	# install docs
	dodoc README
	newdoc debian/README.Debian README.debian
	newdoc debian/changelog ChangeLog.debian
	newdoc CHANGELOG ChangeLog

	# install example configs
	docinto examples
	dodoc ex*conf
}

pkg_preinst() {
	enewgroup ez-ipupd
	enewuser ez-ipupd -1 -1 /var/cache/ez-ipupdate ez-ipupd
}

pkg_postinst() {
	chmod 750 /etc/ez-ipupdate /var/cache/ez-ipupdate
	chown ez-ipupd:ez-ipupd /etc/ez-ipupdate /var/cache/ez-ipupdate

	elog
	elog "Please create one or more config files in"
	elog "/etc/ez-ipupdate/. A bunch of samples can"
	elog "be found in the doc directory."
	elog
	elog "All config files must have a '.conf' extension."
	elog
	elog "Please do not use the 'run-as-user', 'run-as-euser',"
	elog "'cache-file' and 'pidfile' options, since these are"
	elog "handled internally by the init-script!"
	elog
	elog "If you want to use ez-ipupdate in daemon mode,"
	elog "please add 'daemon' to the config file(s) and"
	elog "add the ez-ipupdate init-script to the default"
	elog "runlevel."
	elog
	elog "Without the 'daemon' option, you can run the"
	elog "init-script with the 'update' parameter inside"
	elog "your PPP ip-up script."
	elog

	if [ -f /etc/ez-ipupdate.conf ]; then
		elog "!!! IMPORTANT UPDATE NOTICE !!!"
		elog
		elog "The ez-ipupdate init-script can now handle more"
		elog "than one config file. New config file location is"
		elog "/etc/ez-ipupdate/*.conf"
		elog
		if [ ! -f /etc/ez-ipupdate/default.conf ]; then
			mv -f /etc/ez-ipupdate.conf /etc/ez-ipupdate/default.conf
			elog "Your old configuration has been moved to"
			elog "/etc/ez-ipupdate/default.conf"
			elog
		fi
	fi
}
