# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
RESTRICT=mirror

PYTHON_COMPAT=( python2_7 )
inherit eutils readme.gentoo python-r1

DESCRIPTION="Configurable and full featured FVWM theme, with lots of transparency and freedesktop compatible menu"
HOMEPAGE="http://fvwm-crystal.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="${PYTHON_DEPS}
	x11-misc/xdg-user-dirs
	>=x11-wm/fvwm-2.6.5[png]
	|| ( media-gfx/imagemagick media-gfx/graphicsmagick[imagemagick] )
	|| ( >=x11-misc/stalonetray-0.6.2-r2 x11-misc/trayer )
	|| ( x11-misc/hsetroot media-gfx/feh )
	sys-apps/sed
	sys-devel/bc
	virtual/awk
	x11-apps/xwd"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="After installation, execute following commands:
 $ cp -r ${ROOT}usr/share/doc/${PF}/addons/Xresources ~/.Xresources
 $ cp -r ${ROOT}usr/share/doc/${PF}/addons/Xsession ~/.xinitrc

Many applications can extend functionality of fvwm-crystal.
They are listed in ${ROOT}usr/share/doc/${PF}/INSTALL.gz.

Some icons fixes was committed recently.
To archive the same fixes on your private icon files,
please read ${ROOT}usr/share/doc/${PF}/INSTALL.gz.
This will fix the libpng warnings at stderr.

The color themes was updated to Fvwm InfoStore.
To know how to update your custom color themes, please run
	${ROOT}usr/share/${PN}/addons/convert_colorsets"

src_prepare() {
	sed -i -e 's!/usr/local!${EPREFIX%/}/usr!' -- "${S}/Makefile"
	epatch_user
}

src_install() {
	emake \
		DESTDIR="${D}" \
		docdir="${EPREFIX%/}/usr/share/doc/${PF}" \
		prefix="${EPREFIX%/}/usr" \
		install

	python_replicate_script \
		"${ED}/usr/bin/${PN}".{apps,wallpaper} \
		"${ED}/usr/share/${PN}"/fvwm/scripts/FvwmMPD/*.py
	readme.gentoo_create_doc
}
