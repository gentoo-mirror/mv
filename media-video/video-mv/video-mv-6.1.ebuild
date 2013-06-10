# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="Frontends for using mplayer/mencoder, ffmpeg/libav, or tzap as video recorder"
HOMEPAGE="https://github.com/vaeth/video-mv/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+title zsh-completion"
RDEPEND="app-shells/push
	!<app-shells/runtitle-2.3
	zsh-completion? ( app-shells/runtitle[zsh-completion] )
	|| ( ( media-sound/alsa-utils
			|| ( media-video/mplayer[encode] virtual/ffmpeg ) )
		media-tv/linuxtv-dvb-apps )"
DEPEND=""

src_prepare() {
	epatch_user
}

src_install() {
	local i
	insinto /usr/bin
	for i in bin/*
	do	if test -h "${i}" || ! test -x "${i}"
		then	doins "${i}"
		else	dobin "${i}"
		fi
	done
	insinto /etc
	doins etc/*
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins zsh/*
	fi
	dodoc README
}

pkg_post_install() {
	has_version app-shells/runtitle || elog \
		"Install app-shells/runtitle to let ${PN} update the satatus bar"
	case " ${REPLACING_VERSIONS:-5.}" in
	' '5.*)
		elog "If you use dvb-t with zsh completion, you might want to put"
		elog "zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'"
		elog "into your ~/.zshrc or /etc/zshrc for case-insensitive matching.";;
	esac
}
