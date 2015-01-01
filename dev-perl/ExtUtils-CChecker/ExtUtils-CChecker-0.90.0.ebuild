# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
MODULE_AUTHOR=PEVANS
MODULE_VERSION=0.09
inherit perl-module

DESCRIPTION='configure-time utilities for using C headers,'
LICENSE=" || ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
perl_meta_build() {
	# Module::Build
	echo virtual/perl-Module-Build
	# Test::Fatal
	echo dev-perl/Test-Fatal
	# Test::More
	echo virtual/perl-Test-Simple
}
perl_meta_runtime() {
	# ExtUtils::CBuilder
	echo virtual/perl-ExtUtils-CBuilder
}
DEPEND="
	$(perl_meta_build)
	$(perl_meta_runtime)
"
RDEPEND="
	$(perl_meta_runtime)
"
SRC_TEST="do parallel"
