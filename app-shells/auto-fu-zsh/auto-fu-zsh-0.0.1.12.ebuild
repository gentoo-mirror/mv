# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
RESTRICT="mirror"
inherit eutils vcs-snapshot

pPN=${PN%-zsh}
mPN="${pPN}.zsh"
DESCRIPTION="zsh automatic complete-word and list-choices: incremental completion"
HOMEPAGE="https://github.com/hchbaw/auto-fu.zsh/"
SRC_URI="http://github.com/hchbaw/${mPN}/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+compile"

DEPEND="compile? ( app-shells/zsh )"

DESTPATH="/usr/share/zsh/site-contrib/${pPN}"

generate_example() {
	echo "# Put something like this into your ~/.zshrc"
	if use compile
	then	echo "source ${DESTPATH}/${pPN}
auto-fu-install"
	else	echo "source ${DESTPATH}/${pPN}.zsh"
	fi
	echo "zstyle ':auto-fu:highlight' input bold
zstyle ':auto-fu:highlight' completion fg=yellow
zstyle ':auto-fu:highlight' completion/one fg=blue
zstyle ':auto-fu:var' postdisplay # \$'\\n-azfu-'
zstyle ':auto-fu:var' track-keymap-skip opp
#zstyle ':auto-fu:var' disable magic-space
zle-line-init() auto-fu-init
zle -N zle-line-init
zle -N zle-keymap-select auto-fu-zle-keymap-select
zstyle ':completion:*' completer _oldlist _complete"
}

src_prepare() {
	(
		umask 022
		generate_example >"${S}"/zshrc-example
	)
	epatch_user
}

src_compile() {
	! use compile || zsh -c "source ${mPN} && auto-fu-zcompile ${mPN} ." || die
}

src_install() {
	insinto "${DESTPATH}"
	doins "${mPN}"
	! use compile || doins "${pPN}" "${pPN}.zwc"
	dodoc zshrc-example README*
}
