# Copyright 2012-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="An intelligent prompt for zsh or bash with status line (window title) support"
HOMEPAGE="https://github.com/vaeth/set_prompt/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env "#!'"${EPREFIX}"'/bin/"' \
		-- bin/* || die
	default
}

src_install() {
	insinto /etc
	doins bin/*.config
	insinto /usr/bin
	dobin bin/*.sh bin/*.zsh bin/set_prompt bin/git_update
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	dodoc README.md
}
