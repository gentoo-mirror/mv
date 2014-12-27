# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils linux-info pax-utils readme.gentoo systemd unpacker

# The following variable is only for testing purposes. Leave it to "false"
keep_original=false

DESCRIPTION="Sundtek MediaTV Pro III Drivers"
HOMEPAGE="http://support.sundtek.com/index.php/topic,2.0.html"
# Current version number can be found in http://sundtek.de/media/latest.phtml
SRC_URI="http://www.sundtek.de/media/sundtek_installer_${PV}.sh"

RESTRICT="mirror strip"
LICENSE="sundtek"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="pax_kernel"
RDEPEND="!<sys-apps/openrc-0.13"
DEPEND="pax_kernel? ( || ( sys-apps/elfix sys-apps/paxctl ) )"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="To initialize sundtek drivers during booting call
	rc-update add sundtek default          # for openrc
	systemctl enable sundtek-local.service # for systemd
You will probably need to adapt sundtek-local.service to your defaults
"

QA_PREBUILT="opt/bin/* opt/bin/*/* usr/$(get_libdir)/*"

src_unpack() {
	local subdir a
	a="${S}/archives"
	mkdir -- "${S}" # "|| die" no necessary: test happens in cd
	mkdir -- "${a}"
	cd -- "${a}" || die "cannot cd to ${a}"
	bash -- "${DISTDIR}/${A}" -e || die "extracting failed"
	cd -- "${S}" || die
	if use amd64
	then	subdir=64bit
	elif use x86
	then	subdir=32bit
	else	die "This ebuild does not support the architecture.
Download from Sundtek directly, write your own ebuild, or send me patches."
	fi
	unpacker "${a}/${subdir}/installer.tar.gz" || die
	rm -rf -- "${a}" || die "cannot remove ${a}"
	cp -- \
		"${FILESDIR}"/sundtek.initd \
		"${FILESDIR}"/sundtek-local.service \
		"${FILESDIR}"/_mediaclient \
		"${FILESDIR}"/mediaclient.video \
		"${S}" || die
}

my_movlibdir() {
	local i
	for i in bin/*
	do	if test -d "${i}"
		then	mv "${i}" "${2}" || die
		fi
	done
}

src_prepare() {
	local mybinprefix mylibdir myinclude myinclsundtek mysystemd \
		myudev mypkgconfig mylirc myusr
	if ${keep_original}
	then	mylibdir="opt/lib"
			myinclude="opt/include"
			myusr=
	else	mylibdir="usr/$(get_libdir)"
			myinclude="usr/include"
			myusr="usr"
	fi
	mybinprefix="opt"
	mypkgconfig="usr/share/pkgconfig"
	myinclsundtek="${myinclude}/sundtek"
	myudev="lib/udev"
	mylirc="etc/lirc"
	umask 022
	if use pax_kernel
	then	pax-mark em opt/bin/mediasrv
		pax-mark e opt/bin/mediaclient
	fi
	mv opt 1 || die
	mkdir -p ${myusr} "${mybinprefix}" lib "${mypkgconfig}" "${mylirc}" \
		1/lib/pm-utils || die
	mv 1/bin "${mybinprefix}" || die
	${keep_original} || mv 1/lib/pm 1/lib/pm-utils/sleep.d || die
	mv 1/lib "${mylibdir}" || die
	mv 1/include "${myinclude}" || die
	sed -e "s#/opt/lib#${EPREFIX}/${mylibdir}#" \
		-e "s#/opt/include#${EPREFIX}/${myinclsundtek}#" \
		-e "s#prefix=/opt#prefix=${EPREFIX}/${mybinprefix}#" \
		1/doc/libmedia.pc >"${mypkgconfig}/libmedia.pc" || die
	sed -i -e "s#/opt#${EPREFIX}/${mybinprefix}#" \
		etc/udev/rules.d/*.rules 1/doc/*.service sundtek.initd || die
	sed -i -e "s/^\([^#]\)/#\1/" \
		etc/udev/rules.d/80-mediasrv-eeti.rules || die
	mv etc/udev/rules.d/80-mediasrv.rules etc/hal . || die
	mv etc/udev "${myudev}" || die
	mv 1/doc/hardware.conf 1/doc/sundtek.conf "${mylirc}" || die
	rm 1/doc/lirc_install.sh 1/doc/libmedia.pc || die
	mv 1/doc/*.service "${S}" || die
	mkdir "${S}/doc" && mkdir "${S}/doc/bin" || die
	mv 1/doc/README 1/doc/*.conf "${S}/doc" || die
	mv 1/doc/*.cgi "${S}/doc/bin" || die
	rmdir 1/doc || die "${S}/1/doc contains files not known to the ebuild"
	rmdir 1 || die "${S}/1 contains files not known to the ebuild"
	my_movlibdir "${mylibdir}"
	mkdir etc/revdep-rebuild || die
	echo "SEARCH_DIRS_MASK=\"${EPREFIX}/${mybinprefix}/bin/audio/libpulse.so\"" \
		>etc/revdep-rebuild/50-sundtek-tv
	echo "/${mylibdir}/libmediaclient.so" >etc/ld.so.preload
	ln -sfn mediaclient.video mediaclient.audio
	ln -sfn mediaclient.video mediaclient.dvb
	epatch_user
}

src_install() {
	insinto /
	local i
	for i in etc lib64 lib32 lib usr opt
	do	test -d "${i}" && mv -- "${i}" "${ED}"
	done
	for i in "${ED}"/usr/bin "${ED}"/usr/$(get_libdir) "${ED}"/opt
	do	test -d "${i}" && chmod -R 755 "${i}"
	done
	if ! ${keep_original}
	then	newinitd sundtek.initd sundtek
		systemd_dounit *.service
		dodoc doc/README doc/*.conf
		mv -- doc/bin "${ED}/usr/share/doc/${PF}" || die
		docompress -x "/usr/share/doc/${PF}/bin"
	fi
	dobin mediaclient.video
	insinto /usr/bin
	doins mediaclient.dvb mediaclient.audio
	insinto /usr/share/zsh/site-functions
	doins _mediaclient
	readme.gentoo_create_doc
}

pkg_pretend() {
	local CONFIG_CHECK="~INPUT_UINPUT"
	check_extra_config
}

pkg_postinst() {
	einfo "Adding root to the audio group"
	usermod -aG audio root || {
		ewarn "Could not add root to the audio group."
		ewarn "You should do this manually if you have problems with sound"
	}
	false chmod 6111 "${EPREFIX}/opt/bin/mediasrv" || \
	elog "You might need to chmod 6111 ${EPREFIX}/opt/bin/mediasrv"
}
