# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"

inherit eutils

DESCRIPTION="Wolfgang Friebel's preprocessor for sys-apps/less. Append colon to filename to disable"
HOMEPAGE="http://www-zeuthen.desy.de/~friebel/unix/lesspipe.html"
SRC_URI="http://www-zeuthen.desy.de/~friebel/unix/less/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~m68k ~mips ~ppc ~s390 ~sh ~x86 ~ppc-aix ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="antiword cabextract catdoc +cpio +djvu dpkg +dvi2tty +elinks fastjar +ghostscript gpg +groff +html2text id3v2 image isoinfo libplist +links +lynx lzip mp3info mp3info2 ooffice p7zip pdf pstotext rar rpm +rpm2targz unrar unrtf +unzip +w3m xlhtml"

htmlmode="( || ( html2text links lynx elinks w3m ) )"
REQUIRED_USE="!rpm2targz? ( rpm? ( cpio ) )
	ooffice? ${htmlmode}
	xlhtml? ${htmlmode}"

RDEPEND="sys-apps/file
	app-arch/xz-utils
	app-arch/bzip2
	dev-lang/perl
	sys-apps/less[lesspipe]
	unzip? ( app-arch/unzip )
	fastjar? ( app-arch/fastjar )
	unrar? ( app-arch/unrar )
	!unrar? (
		rar? ( app-arch/rar )
	)
	lzip? ( app-arch/lzip )
	p7zip? ( app-arch/p7zip )
	cpio? ( app-arch/cpio )
	cabextract? ( app-arch/cabextract )
	html2text? ( app-text/html2text )
	!html2text? (
		links? ( www-client/links )
		!links? (
			lynx? ( www-client/lynx )
			!lynx? (
				elinks? ( www-client/elinks )
				!elinks? (
					w3m? ( www-client/w3m )
				)
			)
		)
	)
	groff? ( sys-apps/groff )
	rpm2targz? ( app-arch/rpm2targz )
	!rpm2targz? (
		rpm? ( || ( app-arch/rpm app-arch/rpm5 ) )
	)
	antiword? ( app-text/antiword )
	!antiword? (
		catdoc? ( app-text/catdoc )
	)
	xlhtml? ( app-text/xlhtml )
	unrtf? ( app-text/unrtf )
	ooffice? ( app-text/o3read )
	djvu? ( app-text/djvu )
	dvi2tty? ( dev-tex/dvi2tty )
	pstotext? ( app-text/pstotext )
	!pstotext? (
		ghostscript? ( app-text/ghostscript-gpl )
	)
	gpg? ( app-crypt/gnupg )
	pdf? ( app-text/poppler )
	id3v2? ( media-sound/id3v2 )
	!id3v2? (
		mp3info2? ( dev-perl/MP3-Tag )
		!mp3info2? (
			mp3info? ( media-sound/mp3info )
		)
	)
	image? ( || ( media-gfx/graphicsmagick[imagemagick] media-gfx/imagemagick ) )
	isoinfo? ( || ( app-cdr/cdrtools app-cdr/dvd+rw-tools app-cdr/cdrkit ) )
	libplist? ( app-pda/libplist )
	dpkg? ( app-arch/dpkg )"
DEPEND="${RDEPEND}"

ModifyStart() {
	sedline=
}

Modify() {
	if [ -z "${sedline:++}" ]
	then	sedline='/^__END__$/,${'
	else	sedline=${sedline}';'
	fi
	sedline=${sedline}'s/^\('${1}'[[:space:]][[:space:]]*\)[nNyY]/\1'${2:-Y}'/'
}

ModifyEnd() {
	sedline=${sedline}'}'
	sed -i -e "${sedline}" "${S}/configure"
}

ModifyY() {
	local i
	for i
	do	Modify "${i}"
	done
}

ModifyN() {
	local i
	for i
	do	Modify "${i}" N
	done
}

ModifyX() {
	if [ ${?} -eq 0 ]
	then	ModifyY "${@}"
	else	ModifyN "${@}"
	fi
}

ModifyU() {
	local i
	for i
	do	use "${i}"; ModifyX "${i}"
	done
}

Modify1() {
	local i search
	search=:
	for i
	do	${search} && use "${i}" && search=false; ModifyX "${i}"
	done
}

src_prepare() {
	ModifyStart
	ModifyY 'HILITE'
	ModifyY 'LESS_ADVANCED_PREPROCESSOR'
	ModifyY 'nm'
	ModifyY 'iconv'
	ModifyY 'bzip2'
	ModifyY 'xz' 'lzma'
	ModifyY 'perldoc'
	ModifyU 'unzip' 'fastjar'
	Modify1 'unrar' 'rar'
	ModifyU 'lzip'
	use p7zip; ModifyX '7za'
	ModifyU 'cpio' 'cabextract' 'groff'
	Modify1 'html2text' 'links' 'lynx' 'elinks' 'w3m'
	use rpm2targz; ModifyX 'rpmunpack'
	! use rpm2targz && use rpm; ModifyX 'rpm' 'rpm2cpio'
	Modify1 'antiword' 'catdoc'
	use xlhtml; ModifyX 'ppthtml' 'xlhtml'
	ModifyU 'unrtf'
	use ooffice; ModifyX 'o3tohtml'
	use djvu; ModifyX 'djvutxt'
	ModifyU 'dvi2tty'
	ModifyU 'pstotext'
	! use pstotext && use ghostscript; ModifyX 'ps2ascii'
	ModifyU 'gpg'
	use pdf; ModifyX 'pdftohtml' 'pdftotext'
	Modify1 'id3v2' 'mp3info2' 'mp3info'
	use image; ModifyX 'identify'
	ModifyU 'isoinfo'
	ModifyN 'dpkg'
	ModifyN 'lsbom'
	use libplist; ModifyX 'plutil'
	ModifyEnd
	printf '%s\n' 'LESS_ADVANCED_PREPROCESSOR=1' >70lesspipe
	epatch_user
}

src_configure() {
	./configure --fixed --prefix=/usr
}

src_install() {
	doenvd 70lesspipe
	dodir /usr/share/man/man1
	default
}
