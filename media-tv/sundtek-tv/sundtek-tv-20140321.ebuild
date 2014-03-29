# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils pax-utils readme.gentoo systemd

develop=false
keep_original=false

tar_amd64="${PN}-amd64-${PV}.tar.gz"
tar_x86="${PN}-x86-${PV}.tar.gz"
drivertar="installer.tar.gz"
driverfile="${PN}-20140223.sh"
driverdist="sundtek_netinst.sh"
docfile="${PN}-20090913.pdf"
docdist="sundtek_smart_facts_de.pdf"
DESCRIPTION="Sundtek MediaTV Pro III Drivers"
HOMEPAGE="http://support.sundtek.com/index.php/topic,2.0.html"
SRC_URI="amd64? ( http://www.sundtek.de/media/netinst/64bit/installer.tar.gz -> ${tar_amd64} )
x86? ( http://www.sundtek.de/media/netinst/32bit/installer.tar.gz -> ${tar_x86} )
doc? ( http://www.sundtek.com/docs/${docdist} -> ${docfile} )"
${develop} && SRC_URI="${SRC_URI} http://www.sundtek.de/media/${driverdist} -> ${driverfile}"

RESTRICT="mirror"
LICENSE="sundtek"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="doc pax_kernel"
RDEPEND=""
DEPEND="pax_kernel? ( || ( sys-apps/elfix sys-apps/paxctl ) )"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="To initialize sundtek drivers during booting call
	rc-update add sundtek default    # for openrc
	systemctl enable sundtek.service # for systemd
"

QA_PREBUILT="opt/bin/* usr/lib*"

pkg_setup() {
	if use amd64
	then	sourcetar="${tar_amd64}"
	elif use x86
	then	sourcetar="${tar_x86}"
	else	die "This ebuild does not support the architecture.
Download from Sundtek directly or write your own ebuild"
	fi
	elog "sundtek provides regular updates to the driver."
	elog "I do not have time to bump this ebuild regularly."
	elog "In case of checksum mismatches, copy to your local overlay,"
	elog "rename the ebuild version to the current date and call"
	elog "ebuild [name to the new ebuild] manifest"
	elog "Although the ebuild tries to be generic, there is no guarantee that"
	elog "the most current driver will work in this case, of course."
	elog "If you cannot get this ebuild to work, use sundtek's installer."
}

src_unpack() {
	mkdir "${S}" && cd "${S}"
	unpack ${A}
	cp "${FILESDIR}"/sundtek.initd "${S}"
	! ${develop} || cp "${DISTDIR}/${driverfile}" "${S}/${driverdist}" \
		|| die "could not copy ${driverfile}"
	! use doc || cp "${DISTDIR}/${docfile}" "${S}/${docdist}" \
		|| die "could not copy ${docfile}"
}

extract_driver() {
	local size
	size=`sed -n -e  's/^_SIZE=//p' -- "${S}/${driverdist}"` \
		&& [ -n "${size}" ] || die "cannot determine size"
	dd "if=${S}/${driverdist}" of="${S}/installer.tar.gz" skip=1 "bs=${size}" \
		|| die "failed to extract driver tarball"
	dd "if=${S}/${driverdist}" of="${S}/installer.sh" count=1 "bs=${size}" \
		|| die "failed to extract installer script"
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
	${develop} && extract_driver
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
	# The systemd unit need only be patched if PAX flags are not properly set
	: sed -i -e 's/^\(\(Exec\(Start\|Stop\)\|Type\)=\)/#\1/' \
		-e '/^#ExecStart=/iExecStart=/opt/bin/mediasrv --pluginpath /opt/bin' \
		-e '/^#ExecStop=/i#ExecStop=/bin/kill $MAINPID' \
		1/doc/sundtek.service || die
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
	mv 1/doc/README 1/doc/*.service 1/doc/*.conf "${S}" || die
	rmdir 1/doc || die "${S}/1/doc contains files not known to the ebuild"
	rmdir 1 || die "${S}/1 contains files not known to the ebuild"
	my_movlibdir "${mylibdir}"
	mkdir etc/revdep-rebuild || die
	echo "SEARCH_DIRS_MASK=\"${EPREFIX}/${mybinprefix}/bin/audio/libpulse.so\"" \
		>etc/revdep-rebuild/50-sundtek-tv
	echo "/${mylibdir}/libmediaclient.so" >etc/ld.so.preload
	${develop} && die "Developer mode: Dying after unpacking all"
	cp -- "${FILESDIR}"/_mediaclient .
	epatch_user
}

src_install() {
	insinto /
	local i
	for i in etc lib64 lib32 lib usr opt
	do	test -d "${i}" && doins -r "${i}"
	done
	for i in "${ED}"/usr/bin "${ED}"/usr/lib* "${ED}"/opt
	do	test -d "${i}" && chmod -R 755 "${i}"
	done
	if ! ${keep_original}
	then	newinitd sundtek.initd sundtek
		systemd_dounit *.service
		dodoc README *.conf
		! use doc || dodoc "${docdist}"
	fi
	insinto /usr/share/zsh/site-functions
	doins _mediaclient
	readme.gentoo_create_doc
}

pkg_postinst() {
	false chmod 6111 "${EPREFIX}/opt/bin/mediasrv" || \
	elog "You might need to chmod 6111 ${EPREFIX}/opt/bin/mediasrv"
	einfo "adding root to the audio group."
	usermod -aG audio root || {
		ewarn "Could not add root to the audio group."
		ewarn "You should do this manually if you have problems with sound"
	}
}
