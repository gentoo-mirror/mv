# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils

PNn="${PN}s"
case ${PV} in
99999999*)
	LIVE=:
	EGIT_REPO_URI="git://github.com/zsh-users/${PNn}.git"
	inherit git-r3
	PROPERTIES="live"
	KEYWORDS=""
	SRC_URI="";;
*)
	LIVE=false
	RESTRICT="mirror"
	TARBALL_VERSION='0.11.0'
	SRC_URI="https://github.com/zsh-users/${PNn}/archive/${TARBALL_VERSION}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${PNn}-${TARBALL_VERSION}"
esac

DESCRIPTION="Programmable Completion for zsh (includes emerge and ebuild commands)"
HOMEPAGE="http://gentoo.org/zsh-users/zsh-completions/"
LICENSE="ZSH"
SLOT="0"
DEPEND="completion_pass? ( !app-admin/pass[zsh-completion] )
completion_pip? ( !dev-python/pip[zsh-completion] )"

IUSE="completion_pass completion_pip"
declare -a COMPLETIONS FILES
COMPLETIONS=()
FILES=()
for completion in \
	'+Android _adb _android _emulator' \
	'+Gentoo _baselayout _eselect _gcc-config _genlop _gentoo_packages _gentoolkit _layman _portage _portage_utils' \
	'+Google _google' \
	'+Unix _cmake _dzen2 _logger _ps _shutdown _watch _xinput' \
	'+database _redis-cli _pgsql_utils' \
	'+dev _artisan _choc _console _gradle _geany _phing _manage.py _mvn _pear _play _symfony _thor _vagrant _veewee' \
	'+disk _sdd _smartmontools _srm' \
	'+distribute _celery _envoy _fab _glances _kitchen _knife _mina _mussh' \
	'+filesystem _zfs' \
	'+git _git-flow _git-pulls' \
	'+hardware _optirun _perf _primus' \
	'+haskell _cabal _ghc' \
	'+managers _bower _brew _debuild _lein _packagekit _pactree _pkcon _port _yaourt' \
	'+multimedia _id3 _id3v2 _mpv _showoff' \
	'+net _dget _dhcpcd _httpie _iw _mosh _socat _ssh-copy-id _vpnc _vnstat' \
	'+nfs _exportfs' \
	'+pass _pass' \
	'+perl _cpanm' \
	'+pip _pip' \
	'+python _bpython _pygmentize _setup.py' \
	'+ruby _bundle _cap _ditz _gas _gem _gist _github _git-wtf _lunchy _rails _rubocop _rvm _jekyll' \
	'+search _ack _ag _jq' \
	'+session _atach _attach _teamocil _tmuxinator _wemux' \
	'+subtitles _language_codes _periscope _subliminal' \
	'+virtualization _virtualbox _virsh' \
	'+web _coffee _composer _docpad _drupal _gradle _heroku _jonas _jmeter _jmeter-plugins _lunar _middleman _node _nvm _ralio _salt _sbt _scala _svm'
do	curr=${completion%% *}
	case ${curr} in
	'*'*)
		curr=${curr#?}
		${LIVE} || continue;;
	esac
	case ${curr} in
	'+'*)
		curr="+completion_${curr#?}";;
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
