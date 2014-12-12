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
KEYWORDS=""
IUSE="cron-boot +etc-crontab minutely yearly"

RDEPEND=">=sys-apps/systemd-217
	sys-apps/debianutils"
DEPEND=""

src_prepare() {
	python_setup
	python_fix_shebang --force "${S}/src/bin"
	sed -i \
		-e 's/^crontab/crontab-systemd/' \
		"${S}/src/man/crontab.1.in" || die
	sed -i \
		-e '/install.*bin\/crontab_setuid/d' \
		-e 's/crontab\.1/crontab-systemd\.1/' \
		"${S}/Makefile.in" || die
	mkdir -p "${S}/out/build/man"
	cp "${S}/src/man/crontab.1.in" "${S}/out/build/man/crontab-systemd.1" || die
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
		--enable-persistent=yes
}

src_install() {
	make DESTDIR="${ED}" install
	mv "${ED}"/usr/bin/crontab{,-systemd} || die
	mv "${ED}"/usr/share/man/man1/crontab{,-systemd}.1 || die
	mv "${ED}"/usr/share/man/man5/crontab{,-systemd}.5 || die
}

pkg_postinst() {
	if use etc-crontab && {
		has_version sys-process/dcron || ! has_version virtual/cron
	}
	then	ewarn "sys-process/systemd-cron[etc-crontab] does not work with the /etc/crontab"
		ewarn "installed by sys-process/dcron"
	fi
}
