# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="6"
CHROMIUM_LANGS="cs de en-US es fr it ja kk pt-BR pt-PT ru tr uk zh-CN zh-TW"
inherit chromium-2 unpacker pax-utils

RESTRICT="mirror"

DESCRIPTION="Yandex Browser is a browser that combines a minimal design with sophisticated technology to make the web faster, safer, and easier."
HOMEPAGE="http://browser.yandex.ru/"
LICENSE="Yandex-EULA"
SLOT="0"
SRC_URI="
	amd64? ( http://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/${PN}_${PV}-1_amd64.deb -> ${P}.deb )
"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	>=dev-libs/openssl-1.0.1:0
	gnome-base/gconf:2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-libs/libcap
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/pango[X]
"

QA_PREBUILT="*"
S=${WORKDIR}
YANDEX_HOME="opt/${PN/-//}"

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
    chmod -v 0500 ${WORKDIR}/opt/yandex/browser-beta/yandex_browser-sandbox

	rm usr/bin/${PN} || die

	rm -r etc || die

	rm -r "${YANDEX_HOME}/cron" || die

	mv usr/share/doc/${PN} usr/share/doc/${PF} || die

	pushd "${YANDEX_HOME}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	eapply_user
	
	sed -r \
		-e 's|\[(NewWindow)|\[X-\1|g' \
		-e 's|\[(NewIncognito)|\[X-\1|g' \
		-e 's|^TargetEnvironment|X-&|g' \
		-i usr/share/applications/${PN}.desktop || die
}

src_install() {
	mv * "${D}" || die
	dodir /usr/$(get_libdir)/${PN}/lib
	make_wrapper "${PN}" "./${PN}" "/${YANDEX_HOME}" "/usr/$(get_libdir)/${PN}/lib"
	dosym /usr/$(get_libdir)/libudev.so /usr/$(get_libdir)/${PN}/lib/libudev.so.0

        for icon in "${D}${YANDEX_HOME}/product_logo_"*.png; do
                size="${icon##*/product_logo_}"
                size=${size%.png}
                dodir "/usr/share/icons/hicolor/${size}x${size}/apps"
                newicon -s "${size}" "$icon" "yandex-browser-beta.png"
         done

 #	 pax-mark m "${YANDEX_HOME}/yandex_browser-sandbox"
}

pkg_postinst() {
        ewarn "The SUID sandbox helper binary was found, but is not configured correctly."
        ewarn "You need to make sure that /${YANDEX_HOME}/yandex_browser-sandbox is owned by root and has mode 4755."
        chown root:root "/${YANDEX_HOME}/yandex_browser-sandbox"
        chmod 4755 "/${YANDEX_HOME}/yandex_browser-sandbox"
}

