# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils

PNn="${PN}s"
case ${PV} in
99999999*)
	EGIT_REPO_URI="git://github.com/zsh-users/${PNn}.git"
	EGIT_PROJECT="${PN}.git"
	[ -n "${EVCS_OFFLINE}" ] || EGIT_REPACK=true
	inherit git-2
	PROPERTIES="live"
	SRC_URI=""
	KEYWORDS="";;
*)
	RESTRICT="mirror"
	inherit vcs-snapshot
	SRC_URI="http://github.com/zsh-users/${PNn}/archive/0.8.0.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86";;
esac

DESCRIPTION="Programmable Completion for zsh (includes emerge and ebuild commands)"
HOMEPAGE="http://gentoo.org/zsh-users/zsh-completions/"
LICENSE="ZSH"
SLOT="0"
DEPEND=""

IUSE=""
declare -a COMPLETIONS FILES
COMPLETIONS=()
FILES=()
for completion in \
	'ack _ack' \
	'android _adb _android _emulator' \
	'bumblebee _optirun' \
	'database _redis-cli _pgsql_utils' \
	'dev _choc _gradle _geany _manage.py _mvn _pear _play _symfony _thor _vagrant' \
	'disk _sdd _smartmontools _srm' \
	'distribute _cap _fab _knife _mussh' \
	'+gentoo _baselayout _eselect _gcc-config _genlop _gentoo_packages _gentoolkit _layman _portage _portage_utils' \
	'git _git-flow _git-pulls' \
	'google _google' \
	'haskell _cabal' \
	'managers _brew _debuild _lein _packagekit _pactree _pkcon _port _yaourt' \
	'net _dhcpcd _mosh _ssh-copy-id _vpnc _vnstat' \
	'perf _perf' \
	'perl _cpanm' \
	'pip _pip' \
	'python _bpython _pygmentize _setup.py' \
	'ruby _bundle _ditz _gas _gem _github _git-wtf _lunchy _rvm' \
	'session _attach _teamocil _tmuxinator' \
	'showoff _showoff' \
	'subtitles _language_codes _periscope _subliminal' \
	'virtualbox _virtualbox' \
	'web _coffee _docpad _gradle _heroku _jonas _jmeter _jmeter-plugins _lunar _node _nvm _sbt _scala'
do	curr=${completion%% *}
	case ${curr} in
	'+'*)
		curr="+completion_${curr#'+'}";;
	*)
		curr="completion_${curr}";;
	esac
	IUSE=${IUSE}${IUSE:+ }${curr}
	COMPLETIONS+=("${curr#'+'}")
	FILES+=("${completion#* }")
done

src_prepare() {
	epatch_user
}

src_install() {
	insinto /usr/share/zsh/site-functions
	local i j ok
	for i in src/*
	do	ok=false
		for (( j=0; j<${#FILES[@]}; ++j ))
		do	case " ${FILES[${j}]} " in
			*" ${i#src/} "*)
				ok=:
				use "${COMPLETIONS[$j]}" && doins "${i}" && break;;
			esac
		done
		${ok} || {
			elog "installing unknown completion ${i#*/}"
			doins "${i}"
		}
	done
	dodoc README.md
}
