# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"

MODULE_AUTHOR=PEVANS
MODULE_VERSION=0.02
inherit perl-module

DESCRIPTION="Use the lchown(2) and lutimes(2) system call from Perl"

SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND=""
DEPEND="
	${RDEPEND}
	dev-perl/ExtUtils-CChecker
	virtual/perl-Module-Build"
