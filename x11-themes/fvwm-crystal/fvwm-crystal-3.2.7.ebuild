# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/fvwm-crystal/fvwm-crystal-3.2.3.ebuild,v 1.1 2013/06/23 10:00:55 hwoarang Exp $

EAPI="5"
RESTRICT=mirror

PYTHON_COMPAT=( python2_7 )
inherit eutils readme.gentoo python-r1

DESCRIPTION="Configurable and full featured FVWM theme, with lots of transparency and freedesktop compatible menu"
HOMEPAGE="http://fvwm-crystal.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
#http://sourceforge.net/projects/fvwm-crystal/files/3.2.7/fvwm-crystal-3.2.7.tar.gz/download

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="${PYTHON_DEPS}
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
	find "${S}" -type d -name Applications -prune \
		-o -type f -exec /bin/sh -c 'Echo() {
	printf '\''%s\n'\'' "${*}"
}
Sed() {
	text=${1:-bashisms}
	shift
	cp -p -- "${i}" "${i}.patched" && \
	sed "${@}" \
		-e '\''s/echo -e/echo/'\'' \
		-e '\''s/\[\[ /\[ /g'\'' \
		-e '\''s/ \]\]/ \]/g'\'' \
		-e '\''/\[ | \]/{s/==/=/g}'\'' \
		-e '\''s/source \([^a-z]\)/. \1/g'\'' \
		-- "${i}" >|"${i}.patched" && \
	if diff -q -- "${i}.patched" "${i}" >/dev/null 2>&1
	then	rm -f -- "${i}.patched"
	else	Echo "Fixing ${text} in ${i}"
		mv -- "${i}.patched" "${i}"
	fi && return
	Echo "Failed to patch ${i}" >&2
	exit 1
}
for i
do	case ${i} in
	*.html|*.py|*.png|*.gif|*.jpg|*/ChangeLog)
		continue;;
	*/fvwm-crystal)
		Sed break -e '\''/break;/d'\''
		continue;;
	*/DesktopActions)
		Sed arrays \
			-e '\''/Execs=/{s/[()]/'\''"'\''/g}" \
			-e '\''s/Execs\[\*\]/Execs/'\''
		continue;;
	*/fvwm-crystal.videomodeswitch*)
		Sed shebang -e '\''s:^#!/bin/sh:#!/bin/bash:'\''
		continue;;
	esac
	head -n1 -- "${i}" | grep bash >/dev/null && continue
	if grep -q '\''echo \*'\'' -- "${i}" >/dev/null
	then	Sed quoting -e '\''s/echo \*/echo \\*/g'\''
	else	Sed ""
	fi
done' sh '{}' '+' || die "patching failed"
	epatch_user
}

src_install() {
	emake \
		DESTDIR="${D}" \
		docdir="/usr/share/doc/${PF}" \
		prefix="/usr" \
		install

	python_replicate_script \
		"${D}/usr/bin/${PN}".{apps,wallpaper} \
		"${D}/usr/share/${PN}"/fvwm/scripts/FvwmMPD/*.py
	readme.gentoo_src_install
}
