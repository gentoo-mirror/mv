# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
PYTHON_COMPAT=( pypy python{2_7,3_3,3_4} )
inherit eutils python-single-r1 systemd

DESCRIPTION="systemd units to provide minimal cron daemon functionality by running scripts in cron directories"
HOMEPAGE="https://github.com/dbent/systemd-cron/"
SRC_URI="https://github.com/dbent/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cron-boot +etc-crontab yearly"

RDEPEND=">=sys-apps/systemd-212
	sys-apps/debianutils"
DEPEND=""

src_prepare() {
	python_setup
	python_fix_shebang --force "${S}/src/bin"
	sed -i \
		-e 's/^crontab/crontab-systemd/' \
		"${S}/src/man/crontab.1.in" || die
	use etc-crontab || sed -i \
		-e "s!\\[*'/etc/crontab'\\]*[ +	]*!!" \
		"${S}/src/bin/systemd-crontab-generator" || die
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
		$(my_use_enable yearly) \
		--enable-persistent=yes
}

src_install() {
	emake DESTDIR="${ED}" install
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
