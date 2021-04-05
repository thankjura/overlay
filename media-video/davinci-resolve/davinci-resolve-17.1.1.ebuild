# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit udev desktop xdg-utils preserve-libs

MY_PV=${PV/_beta/b}
MK_RESOLVE_DEB_VERSION="1.4.6"
DESCRIPTION="Professional A/V post-production software suite"
HOMEPAGE="https://www.blackmagicdesign.com/products/davinciresolve/"
PKG_NAME="DaVinci_Resolve_${MY_PV}_Linux"
SRC_URI="davinci-resolve_${MY_PV}-mrd${MK_RESOLVE_DEB_VERSION}_amd64.deb"

RESTRICT="bindist fetch mirror"

KEYWORDS="~amd64"
SLOT="0"
LICENSE="DavinciResolve"

IUSE=""

DEPEND="
	virtual/glu
	dev-qt/qtscript:5
	app-arch/libarchive
	dev-util/patchelf
"

QA_PREBUILT=""

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${PKG_NAME}.zip"
	einfo "from ${HOMEPAGE} and unzip it;"
	einfo "Download makeresolvedeb_${MK_RESOLVE_DEB_VERSION}_multi.sh"
	einfo "from https://www.danieltufvesson.com/makeresolvedeb"
	einfo "then run ./makeresolvedeb_${MK_RESOLVE_DEB_VERSION}_multi.sh ${PKG_NAME}.run"
	einfo "and place out davinci-resolve_${MY_PV}-mrd${MK_RESOLVE_DEB_VERSION}_amd64.deb to ${DISTDIR}"
}

src_unpack(){
	unpack "${A}"
	unpack ./data.tar.xz
	rm *.tar.gz debian-binary
}

src_install() {
	mkdir -p ${D}"/var/BlackmagicDesign/DaVinci Resolve"
	dolib.so usr/lib/libDaVinciPanelAPI.so

	udev_dorules lib/udev/rules.d/75-davincipanel.rules
	udev_dorules lib/udev/rules.d/75-sdx.rules

	cp -f ${FILESDIR}/resolve.xml opt/resolve/share/resolve.xml

	cp -r opt ${D}/opt

	doicon opt/resolve/graphics/DV_Resolve.png
	doicon opt/resolve/graphics/DV_ResolveProj.png

	domenu "usr/share/applications/davinci-resolve-panel-setup.desktop"
	domenu "usr/share/applications/davinci-resolve-braw-speedtest.desktop"
	domenu "usr/share/applications/davinci-resolve-braw-player.desktop"
	domenu "usr/share/applications/davinci-resolve.desktop"

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
