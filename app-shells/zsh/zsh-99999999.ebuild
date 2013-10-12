# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# doc package for -dev version exists?
doc_available=true

inherit eutils flag-o-matic multilib prefix readme.gentoo

MY_PV=${PV/_p/-dev-}
S=${WORKDIR}/${PN}-${MY_PV}

zsh_ftp="ftp://ftp.zsh.org/pub"

if [[ ${PV} != "${MY_PV}" ]] ; then
	ZSH_URI="${zsh_ftp}/development/${PN}-${MY_PV}.tar.bz2"
	if ${doc_available} ; then
		ZSH_DOC_URI="${zsh_ftp}/development/${PN}-${MY_PV}-doc.tar.bz2"
	else
		ZSH_DOC_URI="${zsh_ftp}/${PN}-${PV%_*}-doc.tar.bz2"
	fi
else
	ZSH_URI="mirror://sourceforge/${PN}/${P}.tar.bz2
		${zsh_ftp}/${P}.tar.bz2"
	ZSH_DOC_URI="${zsh_ftp}/${PN}-${PV%_*}-doc.tar.bz2"
fi

DESCRIPTION="UNIX Shell similar to the Korn shell"
HOMEPAGE="http://www.zsh.org/"

case ${PV} in
9999*)
	EGIT_REPO_URI="git://git.code.sf.net/p/zsh/code"
	inherit git-r3
	WANT_LIBTOOL="none"
	inherit autotools
	KEYWORDS=""
	DEPEND="app-text/yodl"
	PROPERTIES="live"
	LIVE=:;;
*)
	SRC_URI="${ZSH_URI}
		doc? ( ${ZSH_DOC_URI} )"
	KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
	DEPEND=""
	PROPERTIES=""
	LIVE=false;;
esac

LICENSE="ZSH gdbm? ( GPL-2 )"
SLOT="0"
IUSE="caps custom-ctype"
COMPLETIONS="AIX BSD Cygwin Darwin Debian +Linux Mandriva openSUSE Redhat Solaris +Unix +X"
for curr in ${COMPLETIONS}
do	case ${curr} in
	[+-]*)
		IUSE="${IUSE} ${curr%%[!+-]*}completion_${curr#?}"
		continue;;
	esac
	IUSE="${IUSE} completion_${curr}"
done
IUSE="${IUSE} debug doc examples gdbm maildir pcre +run-help static unicode"

RDEPEND="
	>=sys-libs/ncurses-5.1
	static? ( >=sys-libs/ncurses-5.7-r4[static-libs] )
	caps? ( sys-libs/libcap )
	pcre? ( >=dev-libs/libpcre-3.9
		static? ( >=dev-libs/libpcre-3.9[static-libs] ) )
	gdbm? ( sys-libs/gdbm )
"
DEPEND="${DEPEND}
	sys-apps/groff
	${RDEPEND}
	run-help? (
		dev-lang/perl
		sys-apps/man
		sys-apps/util-linux
	)"
# run-help needs util-linux for colcrt.
# Please let me know if you have an arch where "colcrt" (or at least "col")
# is provided by a different package.

PDEPEND="
	examples? ( app-doc/zsh-lovers )
"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="
If you want to enable Portage completions and Gentoo prompt,
emerge app-shells/zsh-completion and add
	autoload -U compinit promptinit
	compinit
	promptinit; prompt gentoo
to your ~/.zshrc

Also, if you want to enable cache for the completions, add
	zstyle ':completion::complete:*' use-cache 1
to your ~/.zshrc
"

pkg_setup() {
	if use run-help
	then	DOC_CONTENTS="
If you want to use run-help add to your ~/.zshrc
	unalias run-help
	autoload -Uz run-help
	HELPDIR=/usr/share/zsh/site-contrib/help
${DOC_CONTENTS}"
	fi
}

src_prepare() {
	# fix zshall problem with soelim
	ln -s Doc man1
	mv Doc/zshall.1 Doc/zshall.1.soelim
	soelim Doc/zshall.1.soelim > Doc/zshall.1

	epatch "${FILESDIR}/${PN}"-init.d-gentoo-r1.diff
	if ! ${LIVE} ; then
		epatch "${FILESDIR}/${PN}"-fix-parameter-modifier-crash.patch
		epatch "${FILESDIR}/${PN}"-5.0.2-texinfo-5.1.patch
	fi

	cp -- "${FILESDIR}/_run-help" "${S}/Completion/Zsh/Command/_run-help" || \
			die "cannot copy _run-help completion"

	cp "${FILESDIR}"/zprofile-1 "${T}"/zprofile || die
	eprefixify "${T}"/zprofile || die
	if use prefix ; then
		sed -i -e 's|@ZSH_PREFIX@||' -e '/@ZSH_NOPREFIX@/d' "${T}"/zprofile || die
	else
		sed -i -e 's|@ZSH_NOPREFIX@||' -e '/@ZSH_PREFIX@/d' -e 's|""||' "${T}"/zprofile || die
	fi
	set --
	file='Src/Zle/complete.mdd'
	for i in ${COMPLETIONS}
	do	case ${i} in
		[+-]*)	i=${i#?}
		esac
		grep -q "Completion\/${i}" -- "${S}/${file}" \
			|| die "${file} does not contain Completion/${i}"
		use completion_${i} || set -- "${@}" -e "s/Completion\/${i}[^ ']*//"
	done
	[ ${#} -eq 0 ] || sed -i "${@}" -- "${S}/${file}" \
		|| die "patching ${file} failed"
	epatch_user
	! ${LIVE} || eautoreconf
}

src_configure() {
	local myconf=

	if use static ; then
		myconf+=" --disable-dynamic"
		append-ldflags -static
	fi
	if use debug ; then
		myconf+=" \
			--enable-zsh-debug \
			--enable-zsh-mem-debug \
			--enable-zsh-mem-warning \
			--enable-zsh-secure-free \
			--enable-zsh-hash-debug"
	fi

	if [[ ${CHOST} == *-darwin* ]]; then
		myconf+=" --enable-libs=-liconv"
		append-ldflags -Wl,-x
	fi

	econf \
		--bindir="${EPREFIX}"/bin \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--enable-etcdir="${EPREFIX}"/etc/zsh \
		--enable-fndir="${EPREFIX}"/usr/share/zsh/${PV%_*}/functions \
		--enable-site-fndir="${EPREFIX}"/usr/share/zsh/site-functions \
		--enable-function-subdirs \
		--with-term-lib="ncursesw ncurses" \
		--with-tcsetpgrp \
		$(use_enable maildir maildir-support) \
		$(use_enable pcre) \
		$(use_enable caps cap) \
		$(use_enable unicode multibyte) \
		$(use_enable gdbm ) \
		${myconf}

	if use static ; then
		# compile all modules statically, see Bug #27392
		# removed cap and curses because linking failes
		sed -i \
			-e "s,link=no,link=static,g" \
			-e "/^name=zsh\/cap/s,link=static,link=no," \
			-e "/^name=zsh\/curses/s,link=static,link=no," \
			"${S}"/config.modules || die
		if ! use gdbm ; then
			sed -i '/^name=zsh\/db\/gdbm/s,link=static,link=no,' \
				"${S}"/config.modules || die
		fi
	fi
}

generate_run_help() (
	# We use a subshell (...) for locale overrides and local cd
	# Hence, we also need not declare any variables as local
	mkdir run-help && cd run-help || die "cannot create run-help directory"
	# We need GROFF_NO_SGR to produce "classical" formatting:
	export GROFF_NO_SGR=
	export MANWIDTH=80
	export LANG=C
	unset MANPL MANROFFSEQ LC_ALL
	if [ -z "${LC_CTYPE++}" ] || ! use custom-ctype
	then	local i j=
		unset LC_CTYPE
		for i in `locale -a 2>/dev/null`
		do	case ${i} in
			en*[uU][tT][fF]8*)
				LC_CTYPE=${i}
				break;;
			*[uU][tT][fF]8*)
				[ -n "${LC_CTYPE}" ] || LC_CTYPE=${i};;
			en*|*.*)
				j=${i};;
			esac
		done
		[ -n "${LC_CTYPE}" ] || LC_CTYPE=${j}
		[ -z "${LC_CTYPE}" ] || export LC_CTYPE
	fi
	ebegin "Generating files for run-help"
	# It is necessary to be paranoid about the success of the following pipe,
	# since any change in locale or environment (like unset GROFF_NO_SGR,
	# "bad" LC_CTYPE or tools behaving slightly different) can break it
	# completely. It needs to be tested carefully in each architecture.
	man "${S}/Doc/zshbuiltins.1" | colcrt - | perl "${S}/Util/helpfiles" || {
		eend 1
		eerror "perl Util/helpfiles failed"
		return false
	}
	mystatus=("${PIPESTATUS[@]}")
	[ "${mystatus[0]}" -eq 0 ] || {
		eend 1
		eerror "man Doc/zshbuiltins.1 failed"
		return false
	}
	[ "${mystatus[1]}" -eq 0 ] || {
		eend 1
		eerror "colcrt failed"
		return false
	}
	test -e zmodload || {
		eend 1
		eerror "Could not produce all required files for run-help."
		eerror "This can be caused by a broken locale setting:"
		eerror "Try to set LC_CTYPE to a utf8 aware locale like en_US.UTF-8,"
		eerror "making sure that this locale is supported by your glibc."
		eerror "For compatibility reasons, this ebuild ignores LC_ALL."
		return false
	}
	eend 0
)

src_compile() {
	default
	! use run-help || generate_run_help || {
		error "cannot generate files for run-help."
		die "If this problem cannot be fixed, disable USE=run-help for zsh"
	}
}

src_test() {
	local i
	addpredict /dev/ptmx
	for i in C02cond.ztst Y01completion.ztst Y02compmatch.ztst Y03arguments.ztst ; do
		rm -- "${S}"/Test/${i} || die
	done
	emake check
}

src_install() {
	emake DESTDIR="${ED}" install install.info
	rm -- "${ED}/bin/${PN}-"*

	if use run-help
	then	insinto /usr/share/zsh/site-contrib/help
		doins run-help/*
	fi

	insinto /etc/zsh
	doins "${T}"/zprofile

	keepdir /usr/share/zsh/site-functions
	insinto /usr/share/zsh/${PV%_*}/functions/Prompts
	newins "${FILESDIR}"/prompt_gentoo_setup-1 prompt_gentoo_setup

	# install miscellaneous scripts; bug #54520
	local i
	sed -i -e "s:/usr/local/bin/perl:${EPREFIX}/usr/bin/perl:g" \
		-e "s:/usr/local/bin/zsh:${EPREFIX}/bin/zsh:g" "${S}"/{Util,Misc}/* || die
	for i in Util Misc ; do
		insinto /usr/share/zsh/${PV%_*}/${i}
		doins ${i}/*
	done

	dodoc ChangeLog* META-FAQ NEWS README config.modules
	readme.gentoo_src_install

	if use doc ; then
		pushd "${WORKDIR}/${PN}-${PV%_*}" >/dev/null
		dohtml -r Doc/*
		insinto /usr/share/doc/${PF}
		doins Doc/zsh.{dvi,pdf}
		popd >/dev/null
	fi

	docinto StartupFiles
	dodoc StartupFiles/z*
}
