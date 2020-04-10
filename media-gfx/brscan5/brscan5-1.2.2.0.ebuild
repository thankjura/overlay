# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib rpm readme.gentoo-r1 udev

MY_P="${PN}-${PV%.*}-${PV##*.}"
DESCRIPTION="Brother scanner driver"
HOMEPAGE="http://www.brother.com/"
SRC_URI="
	amd64? ( http://download.brother.com/welcome/dlf104036/${MY_P}.x86_64.rpm )
	x86? ( http://download.brother.com/welcome/dlf104035/${MY_P}.i386.rpm )"

LICENSE="Brother-lpr no-source-code"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="strip"

RDEPEND="media-gfx/sane-backends"

S="${WORKDIR}/opt/brother/scanner/${PN}"

src_install() {
	local lib=$(get_libdir)
	local dest="opt/brother/scanner/"${PN}

	insinto /etc/${dest}
	doins brscan5.ini brsanenetdevice.cfg
	doins -r models

	local libs=(libLxBsNetDevAccs libLxBsDeviceAccs libLxBsUsbDevAccs)
	for l in "${libs[@]}"; do
		dolib.so $l.so.1.0.0
		dosym $l.so.1.0.0 /usr/${lib}/$l.so.1
		dosym $l.so.1.0.0 /usr/${lib}/$l.so
	done

	dolib.so libLxBsScanCoreApi.so.2.0.0
	dosym libLxBsScanCoreApi.so.2.0.0 /usr/${lib}/libLxBsScanCoreApi.so.2
	dosym libLxBsScanCoreApi.so.2.0.0 /usr/${lib}/libLxBsScanCoreApi.so

	insinto /usr/${lib}/sane
	doins libsane-brother5.so.1.0.7
	dosym /usr/${lib}/sane/libsane-brother5.so.1.0.7 /usr/${lib}/sane/libsane-brother5.so.1
	dosym /usr/${lib}/sane/libsane-brother5.so.1.0.7 /usr/${lib}/sane/libsane-brother5.so


	dosym "${EPREFIX}"/etc/${dest}/brscan5.ini /${dest}/brscan5.ini
	dosym "${EPREFIX}"/etc/${dest}/brsanenetdevice.cfg /${dest}/brsanenetdevice.cfg
	dosym "${EPREFIX}"/etc/${dest}/models /${dest}/models

	exeinto ${dest}
	doexe brsaneconfig5 brscan_cnetconfig brscan_gnetconfig
	dosym /${dest}/brsaneconfig5 /usr/bin/brsaneconfig5

	insinto /etc/sane.d/dll.d
	newins - ${PN}.conf <<< "brother5"

	DOC_CONTENTS="If want to use a remote scanner over the network,
		you will have to add it with \"brsaneconfig5\"."
	readme.gentoo_create_doc

	dodoc doc/readme.txt

	udev_newrules udev-rules/NN-brother-mfp-brscan5-1.0.2-2.rules 40-${PN}.rules
}

pkg_postinst() {
	readme.gentoo_print_elog
}
