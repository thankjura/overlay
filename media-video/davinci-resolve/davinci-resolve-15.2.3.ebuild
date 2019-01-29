# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit udev desktop xdg-utils

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
	dev-qt/qtscript:5
	dev-libs/libisoburn
"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${PKG_NAME}.zip"
	einfo "from ${HOMEPAGE} and place it in ${DISTDIR}"
}

src_unpack() {
	default
	xorriso -osirrox on -indev "./${PKG_NAME}.run" -extract / ${S} || die
}

src_prepare() {
	eapply_user
}

src_install() {
	mkdir -p "${D}/opt/resolve/Media"
	mkdir -p "${D}/opt/resolve/DolbyVision"
	mkdir -p "${D}/opt/resolve/configs"
	mkdir -p "${D}/opt/resolve/easyDCP"
	mkdir -p "${D}/opt/resolve/Resolve Disk Database"
	mkdir -p "${D}/opt/resolve/Fairlight"
	mkdir -p "${D}/opt/resolve/.crashreport"
	mkdir -p "${D}/opt/resolve/.license"
	mkdir -p "${D}/opt/resolve/.LUT"
	mkdir -p "${D}/opt/resolve/logs"

	sed -i -- 's/RESOLVE_INSTALL_LOCATION/\/opt\/resolve/g' share/*.desktop

	insinto /opt/resolve
	insopts -m751
	doins -r Control
	doins -r libs
	doins -r plugins
	doins -r LUT
	doins -r share
	doins -r UI_Resource
	insopts -m744
	doins -r docs
	doins -r Fusion
	doins -r Developer
	doins -r graphics
	doins -r Onboarding

	cp -a share/default-config-linux.dat ${D}/opt/resolve/configs/config.dat
	cp -a share/log-conf.xml ${D}/opt/resolve/configs/log-conf.xml
	# cp -a share/default_cm_config.bin ${D}/opt/resolve/DolbyVision/config.bin

	fperms 0744 "/opt/resolve/configs/config.dat"
	fperms 0744 "/opt/resolve/configs/log-conf.xml"
	fperms 0775 "/opt/resolve/configs"
	fperms 0775 "/opt/resolve/Resolve Disk Database"
	fperms 0775 "/opt/resolve/Fairlight"
	fperms 0775 "/opt/resolve/easyDCP"
	fperms 0775 "/opt/resolve/LUT"
	fperms 0775 "/opt/resolve/.LUT"
	fperms 0775 "/opt/resolve/.crashreport"
	fperms 0775 "/opt/resolve/.license"
	fperms 0775 "/opt/resolve/Media"
	fperms 0775 "/opt/resolve/DolbyVision"
	fperms 0775 "/opt/resolve/Developer"
	fperms 0775 "/opt/resolve/logs"

	exeinto /opt/resolve/bin
	doexe bin/*
	exeinto /opt/resolve/scripts
	doexe scripts/*

	# udev rules
	echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="1edb", MODE="0666"' > 75-davincipanel.rules
	echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"' > 75-sdx.rules
	udev_dorules 75-davincipanel.rules
	udev_dorules 75-sdx.rules

	dobin ${FILESDIR}/resolve

	#ln -s "/tmp/resolve/logs" "${D}/opt/resolve/logs"

	domenu share/DaVinciResolve.desktop
	domenu share/DaVinciResolveCaptureLogs.desktop
}

pkg_postinst() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}
