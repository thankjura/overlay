# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit udev desktop xdg-utils preserve-libs

MY_PV=${PV/_beta/b}

DESCRIPTION="Professional A/V post-production software suite"
HOMEPAGE="https://www.blackmagicdesign.com/products/davinciresolve/"
PKG_NAME="DaVinci_Resolve_${MY_PV}_Linux"
SRC_URI="https://sw.blackmagicdesign.com/DaVinciResolve/v${MY_PV}/${PKG_NAME}.zip"

RESTRICT="fetch mirror strip"

KEYWORDS="~amd64"
SLOT="0"
LICENSE="DavinciResolve"

IUSE=""

DEPEND="
	virtual/glu
	dev-qt/qtscript:5
	app-arch/libarchive
"

QA_PREBUILT="opt/resolve"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${PKG_NAME}.zip"
	einfo "from ${HOMEPAGE} and place it in ${DISTDIR}"
}

src_prepare() {
	eapply_user
}

src_install() {
	mkdir -p -m 0775 "${D}/opt/resolve/"{configs,DolbyVision,easyDCP,Fairlight,GPUCache,logs,Media,"Resolve Disk Database",.crashreport,.license,.LUT}

	bsdtar x -f ${PKG_NAME}.run -C "${D}/opt/resolve/"

	RD=${D}/opt/resolve

	insinto /opt/resolve/configs
	newins ${RD}/share/default-config.dat config.dat
	doins ${RD}/share/log-conf.xml
	insinto /opt/resolve/DolbyVision
	newins ${RD}/share/default_cm_config.bin config.bin

	domenu "${RD}/share/DaVinciResolve.desktop"
	domenu "${RD}/share/DaVinciResolvePanelSetup.desktop"
	domenu "${RD}/share/DaVinciResolveInstaller.desktop"
	domenu "${RD}/share/DaVinciResolveCaptureLogs.desktop"

	insinto /usr/share/desktop-directories
	doins ${RD}/share/DaVinciResolve.directory
	insinto /etc/xdg/menus
	doins ${RD}/share/DaVinciResolve.menu

	for _file in $(find ${D}/usr/share ${D}/etc -type f -name *.desktop -o -name *.directory -o -name *.menu | xargs)
	do
		sed -i "s|RESOLVE_INSTALL_LOCATION|/opt/resolve|g" $_file
	done


	echo "StartupWMClass=resolve" >> "${D}/usr/share/applications/DaVinciResolve.desktop"

	# udev rules
	echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="1edb", MODE="0666"' > 75-davincipanel.rules
	echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"' > 75-sdx.rules
	udev_dorules 75-davincipanel.rules
	udev_dorules 75-sdx.rules

	doicon ${RD}/graphics/DV_Resolve.png
	doicon ${RD}/graphics/DV_ResolveProj.png

	dosym /opt/resolve/share/resolve.xml /usr/share/mime/packages/resolve.xml
	dobin ${FILESDIR}/resolve
}

pkg_postinst() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}
