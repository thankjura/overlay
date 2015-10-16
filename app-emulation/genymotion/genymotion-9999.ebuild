# Copyright open-overlay 2015 by Alex
EAPI=5
inherit eutils

DESCRIPTION="Genymotion Emulator"
HOMEPAGE="http://genymotion.com"
SRC_URI="https://github.com/manson9/${PN}/archive/master.tar.gz -> ${P}.tar.gz"
LICENSE="Genymotion"
SLOT="0"
KEYWORDS="amd64"
IUSE="qt4 qt5"
RDEPEND="|| ( >=app-emulation/virtualbox-4.3.12 >=app-emulation/virtualbox-bin-4.3.12 )
        qt4? ( dev-qt/qtwebkit:4 )      
        qt5? ( dev-qt/qtwebkit:5 )"

pkg_postinst() {
               echo 
               elog "Welcome to Genymotion Emulator"
               elog "To run Genymotion virtual devices, you must install Oracle VM VirtualBox 4.1 or above."
               elog "However, for performance reasons, we recommend using version 4.3.12."
               elog "Thanks open-overlay 2015 by Alex"
               echo 
}
src_unpack() {
	unpack "${A}"
	mv "${PN}-master" "${P}"
}
QA_PREBUILT="
   opt/${PN}/${PN}/*.so
   opt/${PN}/${PN}/${PN}-tool
   opt/${PN}/${PN}/libqca.so.2
   opt/${PN}/${PN}/plugins/libvboxmanage.so.1.0.0
   opt/${PN}/${PN}/tools/adb
   opt/${PN}/${PN}/tools/aapt
   opt/${PN}/${PN}/player
   opt/${PN}/${PN}/genyshell
   opt/${PN}/${PN}/${PN}
   opt/${PN}/${PN}/device-upgrade
   opt/${PN}/${PN}/libavutil.so.51
   opt/${PN}/${PN}/libswscale.so.2
   opt/${PN}/${PN}/libprotobuf.so.7
"

src_install() {
	local dir="/opt/${PN}"
	insinto ${dir}
	doins -r *
	fperms 755 "${dir}/${PN}/${PN}" "${dir}/${PN}/player" "${dir}/${PN}/gmtool"   
	newicon "${PN}/icons/icon.png" "${PN}.png" 
	make_wrapper ${PN} ${dir}/${PN}/${PN} 
	make_desktop_entry ${PN} "Genymotion" ${PN} "System;Emulator"
}
