# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="git://github.com/robbyrussell/${PN}.git"
inherit git-r3 readme.gentoo-r1

DESCRIPTION="A ready-to-use zsh configuration with plugins"
HOMEPAGE="https://github.com/robbyrussell/oh-my-zsh"
SRC_URI=""

LICENSE="ZSH"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x64-cygwin ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
PROPERTIES="live"

RDEPEND="app-shells/zsh"

ZSH_DEST="/usr/share/zsh/site-contrib/${PN}"
ZSH_EDEST="${EPREFIX}${ZSH_DEST}"
ZSH_TEMPLATE="templates/zshrc.zsh-template"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="In order to use ${CATEGORY}/${PN} add to your ~/.zshrc
source '${ZSH_DEST}/${ZSH_TEMPLATE}'
or copy a modification of that file to your ~/.zshrc
If you just want to try, enter the above command in your zsh."

src_prepare() {
	local i
	for i in "${S}"/tools/*install* "${S}"/tools/*upgrade*
	do	test -f "${i}" && : >"${i}"
	done
	sed -i -e 's!^ZSH=.*$!ZSH='"${ZSH_EDEST}"'!' \
		   -e 's!~/.oh-my-zsh!'"${ZSH_EDEST}"'!' "${S}/${ZSH_TEMPLATE}"
	sed -i -e 's!~/.oh-my-zsh!'"${ZSH_EDEST}"'!' \
		"${S}/plugins/dirpersist/dirpersist.plugin.zsh"
	sed -i -e '/zstyle.*cache/d' "${S}/lib/completion.zsh"
	eapply_user
}

src_install() {
	insinto "${ZSH_DEST}"
	doins -r *
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
