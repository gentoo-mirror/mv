# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
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
IUSE="+compile +kill-line"

DEPEND="compile? ( app-shells/zsh )"

DESTPATH="/usr/share/zsh/site-contrib/${pPN}"

generate_example() {
	echo "# Put something like the following into your ~/.zshrc
# The interplay with zsh-syntax-highlighting is not perfect yet, but it
# somewhat works if you source zsh-syntax-highlighting after that code.

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
	! use compile || zsh -c "source ${mPN} && auto-fu-zcompile ${mPN} ." || die
}

src_install() {
	insinto "${DESTPATH}"
	doins "${mPN}"
	! use compile || doins "${pPN}" "${pPN}.zwc"
	dodoc zshrc-example README*
}
