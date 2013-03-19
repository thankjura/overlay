# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit eutils

VER="F"

DESCRIPTION="Lightworks is the fastest, most accessible and focused NLE in the industry"
HOMEPAGE="http://www.lwks.com/"
SRC_URI="http://www.lwks.com/dmpub/lwks-${PV}.${VER}-amd64.deb"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch"
IUSE=""

RDEPEND="
    dev-libs/glib
    dev-libs/atk
    dev-libs/expat
    dev-libs/libffi
    sys-apps/dbus
    sys-fs/udev
    x11-libs/pango
    x11-libs/gdk-pixbuf
    x11-libs/cairo
    x11-libs/pixman
    x11-libs/gtk+:3
    dev-qt/qtgui
    x11-libs/qtcore
    virtual/jpeg
    media-libs/libpng
    media-libs/tiff:3
    >=media-libs/freetype-2
    media-libs/fontconfig
    media-libs/mesa
    media-libs/glu
    media-gfx/nvidia-cg-toolkit
    x11-libs/libxcb
    x11-libs/libXinerama
    x11-libs/libXrandr
    x11-libs/libXcursor
    x11-libs/libXext
    x11-libs/libXi
    x11-libs/libXcomposite
    x11-libs/libXdamage
    x11-libs/libXrender
    x11-libs/libXfixes
    x11-libs/libICE
    x11-libs/libSM
    x11-libs/libX11
    x11-libs/libXau
    x11-libs/libXdmcp
    x11-libs/libdrm
    app-accessibility/at-spi2-core
"

DEPEND="${RDEPEND}
    !app-arch/deb2targz
    app-arch/unzip
    x11-apps/mkfontdir"

S="${WORKDIR}"

pkg_nofetch() {
    einfo "Please download"
    einfo "  - lwks-${MY_PV}-amd64.deb"
    einfo "from ${HOMEPAGE} and place it in ${DISTDIR}"
}

pkg_setup() {
    :;
}

src_unpack() {
    unpack ${A}
    unpack ./data.tar.gz
    #unpack ./control.tar.gz
}

src_prepare() {
    # Generate a machine number (if there isn't one already)
    if [ ! -f /usr/share/${PN}/machine.num ];
    then
        cat > usr/share/${PN}/machine.num << EOF
        $((`cat /dev/urandom|od -N1 -An -i` % 2500))
EOF
    else
        cat /usr/share/${PN}/machine.num > usr/share/${PN}/machine.num
    fi
}

src_compile() {
    :;
}

src_install() {
	insinto /usr/lib64/${PN}
	doins -r usr/lib/${PN}/* || die "doins lib failed"

	exeinto /usr/lib64/${PN}
	doexe usr/lib/${PN}/spawn || die "doins lib-exe failed"
	doexe usr/lib/${PN}/ntcardvt || die "doins lib-exe failed"

	insinto "/usr/bin/"
	doins usr/bin/lightworks || die

	fperms a+rw "usr/share/lightworks/Preferences"
	fperms a+rw "usr/share/lightworks/Audio Mixes"

	insinto /usr/share/${PN}
	doins -r usr/share/${PN}/* || die "doins share failed"

	insinto /usr/share/applications
	doins usr/share/applications/* || die "doins desktop application failed"

	insinto /usr/share/fonts
	doins -r usr/share/fonts/* || die "doins fonts failed"
	mkfontdir ${D}/usr/share/fonts/truetype

	dodoc usr/share/doc/${PN}/*
}
