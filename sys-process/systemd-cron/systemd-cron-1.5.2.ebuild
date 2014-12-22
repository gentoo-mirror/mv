# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
PYTHON_COMPAT=( pypy3 python{3_3,3_4} )
inherit eutils python-single-r1 systemd

DESCRIPTION="systemd units to provide minimal cron daemon functionality by running scripts in cron directories"
HOMEPAGE="https://github.com/systemd-cron/systemd-cron/"
SRC_URI="https://github.com/systemd-cron/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cron-boot +etc-crontab minutely setgid yearly"

COMMON_DEPEND="sys-process/cronbase"
RDEPEND=">=sys-apps/systemd-217
	sys-apps/debianutils
	${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

src_prepare() {
	python_setup
	python_fix_shebang --force "${S}/src/bin"
	sed -i \
		-e 's/^crontab/crontab-systemd/' \
		-e 's/^CRONTAB/CRONTAB-SYSTEMD/' \
		"${S}/src/man/crontab."{1,5}".in" || die
	sed -i \
		-e 's!/crontab$!/crontab-systemd!' \
		-e 's!/crontab\(\.[15]\)$!/crontab-systemd\1!' \
		"${S}/Makefile.in" || die
	use etc-crontab || sed -i \
		-e "s!/etc/crontab!/dev/null!" \
		"${S}/src/bin/systemd-crontab-generator.py" || die
	epatch_user
}

my_use_enable() {
	if use ${1}
	then	echo --enable-${2:-${1}}=yes
	else	echo --enable-${2:-${1}}=no
	fi
}

src_configure() {
	./configure \
		--prefix="${EPREFIX}/usr" \
		--confdir="${EPREFIX}/etc" \
		--runparts="${EPREFIX}/bin/run-parts" \
		--mandir="${EPREFIX}/usr/share/man" \
		--unitdir="$(systemd_get_unitdir)" \
		$(my_use_enable cron-boot boot) \
		$(my_use_enable minutely) \
		$(my_use_enable yearly) \
		$(my_use_enable yearly quarterly) \
		$(my_use_enable yearly semi_annually) \
		$(my_use_enable setgid) \
		--enable-persistent=yes
}

pkg_postinst() {
	if use etc-crontab && {
		has_version sys-process/dcron || ! has_version virtual/cron
	}
	then	ewarn "sys-process/systemd-cron[etc-crontab] does not work with the /etc/crontab"
		ewarn "installed by sys-process/dcron"
	fi
}
