# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils

pPN=${PN%-zsh}
mPN="${pPN}.zsh"
case ${PV} in
99999999*)
	EGIT_REPO_URI="git://github.com/hchbaw/${mPN}.git"
	EGIT_PROJECT="${PN}.git"
	EGIT_BRANCH="pu"
	[ -n "${EVCS_OFFLINE}" ] || EGIT_REPACK=true
	inherit git-2
	PROPERTIES="live"
	SRC_URI=""
	KEYWORDS="";;
*)
	RESTRICT="mirror"
	inherit vcs-snapshot
	SRC_URI="http://github.com/hchbaw/${mPN}/tarball/v${PV} -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86";;
esac

DESCRIPTION="zsh automatic complete-word and list-choices: incremental completion"
HOMEPAGE="https://github.com/hchbaw/auto-fu.zsh/"

LICENSE="HPND"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+compile +kill-line"

DEPEND="compile? ( app-shells/zsh )"

DESTPATH="/usr/share/zsh/site-contrib/${pPN}"

generate_example() {
	echo "# Put something like the following into your ~/.zshrc

# First, we set sane options for the standard completion system:

autoload -Uz compinit is-at-least
compinit -D -u
zstyle ':completion:*' completer _oldlist _complete
zstyle ':completion:*' list-colors \${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=1 # interactive
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' path-completion false
if is-at-least 4.3.10
then	zstyle ':completion:*' format \"%B%F{yellow}%K{blue}%d%k%f%b\"
else	zstyle ':completion:*' format \"%B%d%b\"
fi

# Now we source ${PN}"
	if use compile
	then	echo ". ${DESTPATH}/${pPN}
auto-fu-install"
	else	echo ". ${DESTPATH}/${pPN}.zsh"
	fi
	echo "
# Finally, we configure ${PN}

zstyle ':auto-fu:highlight' input
zstyle ':auto-fu:highlight' completion bold,fg=blue
zstyle ':auto-fu:highlight' completion/one fg=blue
zstyle ':auto-fu:var' postdisplay # \$'\\n-azfu-'
#zstyle ':auto-fu:var' enable all
#zstyle ':auto-fu:var' track-keymap-skip opp
#zstyle ':auto-fu:var' disable magic-space
zle-line-init() auto-fu-init
zle -N zle-line-init
zle -N zle-keymap-select auto-fu-zle-keymap-select"
}

src_prepare() {
	(
		umask 022
		generate_example >"${S}"/zshrc-example
	)
	# Make Ctrl-D return correctly.
	# In case of nonempty buffer act like kill-line or kill-whole-line.
	if use kill-line
	then	epatch "${FILESDIR}"/kill-line.patch
	else	epatch "${FILESDIR}"/exit.patch
	fi
	# Reset color with "return":
	epatch "${FILESDIR}"/reset-color.patch
	# Make it work with older zsh versions:
	epatch "${FILESDIR}"/zsh-compatibility.patch
	epatch_user
}

src_compile() {
	! use compile || mPN="${mPN}" \
		zsh -c 'source ${mPN} && auto-fu-zcompile ${PWD}/${mPN} ${PWD}' || die
}

src_install() {
	insinto "${DESTPATH}"
	doins "${mPN}"
	! use compile || doins "${pPN}" "${pPN}.zwc"
	dodoc zshrc-example README*
}
