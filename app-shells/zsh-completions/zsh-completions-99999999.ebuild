# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils

case ${PV} in
99999999*)
	LIVE=:
	EGIT_REPO_URI="git://github.com/zsh-users/${PN}.git"
	inherit git-r3
	PROPERTIES="live"
	KEYWORDS=""
	SRC_URI="";;
*)
	LIVE=false
	RESTRICT="mirror"
	TARBALL_VERSION='0.12.0'
	SRC_URI="https://github.com/zsh-users/${PN}/archive/${TARBALL_VERSION}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${PN}-${TARBALL_VERSION}"
esac

DESCRIPTION="Additional completion definitions for Zsh"
HOMEPAGE="https://gentoo.org/zsh-users/zsh-completions/"
LICENSE="ZSH"
SLOT="0"
DEPEND="completion_pip? ( !dev-python/pip[zsh-completion] )"

IUSE=""
declare -a FILES
FILES=()
declare -A USEFILE FILEINDEX
USEFILE=()
FILEINDEX=()
for completion in \
	'+Android _adb _android _emulator' \
	'+Google _google' \
	'+Unix _cmake _dzen2 _logger _nl _ps _shutdown _watch _xinput' \
	'+database _redis-cli _pgsql_utils' \
	'+dev _artisan _choc _console _gradle _geany _phing _manage.py _mvn _pear _play _symfony _thor _vagrant _veewee' \
	'+disk _sdd _smartmontools _srm' \
	'+distribute _celery _envoy _fab _glances _kitchen _knife _mina _mussh' \
	'+filesystem _zfs' \
	'+git _git-flow _git-pulls' \
	'+hardware _optirun _perf _primus' \
	'+haskell _cabal _ghc' \
	'+managers _bower _brew _debuild _lein _pactree _pkcon _port _yaourt' \
	'+multimedia _id3 _id3v2 _showoff' \
	'+net _dget _dhcpcd _httpie _iw _mosh _rfkill _socat _ssh-copy-id _vpnc _vnstat' \
	'+nfs _exportfs' \
	'+perl _cpanm' \
	'+pip _pip' \
	'+python _bpython _pygmentize _setup.py' \
	'+ruby _bundle _cap _ditz _gas _gem _gist _github _git-wtf _jekyll _lunchy _rails _rspec _rubocop _rvm' \
	'+search _ack _ag _jq' \
	'+session _atach _teamocil _tmuxinator _wemux' \
	'+subtitles _language_codes _periscope _subliminal' \
	'+virtualization _boot2docker _docker _virtualbox _virsh' \
	'+web _coffee _composer _docpad _drush _heroku _jonas _jmeter _jmeter-plugins _lunar _middleman _node _nvm _ralio _salt _sbt _scala _svm'
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
	for currfile in ${completion#* }
	do	USEFILE["${currfile}"]="${curr#'+'}"
		[[ -z ${FILEINDEX["${currfile}"]} ]] || die "${currfile} listed twice"
		FILEINDEX["${currfile}"]="${#FILES[@]}"
		FILES+=("${currfile}")
	done
done

src_prepare() {
	epatch_user
}

src_install() {
	insinto /usr/share/zsh/site-functions
	local i j u
	for i in src/*
	do	j=${i#src/}
		u=${USEFILE["${j}"]}
		if [ -z "${u}" ]
		then	elog "installing unknown completion ${i#*/}"
				doins "${i}"
				continue
		fi
		! use "${u}" || doins "${i}"
		u=${FILEINDEX["${j}"]}
		FILES[${u}]=
	done
	for i in ${FILES[*]}
	do	elog "listed file ${i} not found"
	done
	dodoc README.md zsh-completions-howto.org
}
