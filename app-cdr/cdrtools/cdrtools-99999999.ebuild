# Copyright 1999-2024 Martin V\"ath and others
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A set of tools for CD/DVD reading and recording, including cdrecord"
HOMEPAGE="https://sourceforge.net/projects/cdrtools/"
SRC_URI=""

LICENSE="GPL-2 LGPL-2.1 CDDL-Schily"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="schily-tools"
REQUIRED_USE="schily-tools"

RDEPEND="app-shells/schily-tools[schilytools_cdrtools]"
