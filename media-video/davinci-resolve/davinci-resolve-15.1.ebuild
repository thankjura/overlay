# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit udev desktop

DESCRIPTION="Professional A/V post-production software suite"
HOMEPAGE="https://www.blackmagicdesign.com/products/davinciresolve/"
PKG_NAME="DaVinci_Resolve_${PV}_Linux"
SRC_URI="https://sw.blackmagicdesign.com/DaVinciResolve/v${PV}/${PKG_NAME}.zip"

RESTRICT="fetch mirror strip"

KEYWORDS="~amd64"
SLOT="0"
LICENSE="DavinciResolve"

IUSE=""

DEPEND="
	virtual/glu
"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${PKG_NAME}.zip"
	einfo "from ${HOMEPAGE} and place it in ${DISTDIR}"
}

src_unpack() {
	default
	"./${PKG_NAME}.sh" --tar xf -C ${S} || die
}

src_prepare() {
	eapply_user
}

src_install() {
	dodoc "Linux_Installation_Instructions.pdf"
	dodoc "DaVinci_Resolve_Manual.pdf"

	mkdir -p ${D}/opt/resolve/DolbyVision
	mkdir -p ${D}/opt/resolve/Media
	mkdir -p ${D}/opt/resolve/configs

	insinto /opt/resolve
	insopts -m644
	doins -r UI_Resource
	doins -r libs
	doins -r plugins
	doins -r Developer
	doins -r LUT
	doins -r Onboarding
	doins -r rsf/Control

	insinto /opt/resolve/graphics
	insopts -m644
	doins rsf/DV_Resolve.png

	cp -a rsf/default-config-linux.dat ${D}/opt/resolve/configs/config.dat
	cp -a rsf/log-conf.xml ${D}/opt/resolve/configs/log-conf.xml
	cp -a rsf/default_cm_config.bin ${D}/opt/resolve/DolbyVision/config.bin
	fperms 0644 /opt/resolve/configs/config.dat
	fperms 0644 /opt/resolve/configs/log-conf.xml
	fperms 0755 /opt/resolve/DolbyVision/config.bin
	fperms 0777 /opt/resolve/configs
	fperms 0777 /opt/resolve/Media

	exeinto /opt/resolve/bin
	doexe panels/DaVinciPanelDaemon
	doexe resolve
	doexe rsf/run_bmdpaneld
	doexe rsf/bmdpaneld
	doexe rsf/BMDPanelFirmware
	doexe rsf/DPDecoder
	doexe rsf/qt.conf
	doexe rsf/ShowDpxHeader
	doexe rsf/TestIO
	doexe rsf/deviceQuery
	doexe rsf/bandwidthTest
	doexe rsf/oclDeviceQuery
	doexe rsf/oclBandwidthTest
	doexe rsf/VstScanner

	tar xf panels/libusb-1.0.tgz -C ${D}/opt/resolve/bin
	tar xf panels/dvpanel-framework-linux-x86_64.tgz -C ${D}/opt/resolve/libs
	tar xf panels/dvpanel-utility-linux-x86_64.tgz -C ${D}/opt/resolve

	for archive in ${D}/opt/resolve/libs/*tgz; do
		tar xf "${archive}" -C ${D}/opt/resolve/libs/
		rm -f "${archive}"
	done

	unzip -qo rsf/fusion_presets.zip -d ${D}/opt/resolve
	gunzip -f ${D}/opt/resolve/LUT/trim_lut0.dpx.gz
	# udev rules
	echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="1edb", MODE="0666"' > 75-davincipanel.rules
	echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"' > 75-sdx.rules
	udev_dorules 75-davincipanel.rules
	udev_dorules 75-sdx.rules

	dobin ${FILESDIR}/resolve

	ln -s "/tmp/resolve/logs" "${D}/opt/resolve/logs"
	ln -s "/tmp/resolve/GPUCache" "${D}/opt/resolve/GPUCache"

	make_desktop_entry resolve "Davinci Resolve" /opt/resolve/graphics/DV_Resolve.png
}
