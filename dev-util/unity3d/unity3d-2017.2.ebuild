# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils eutils

BUILD_HASH=2b451a7da81d
MY_PV=${PV}.0xb6Linux

DESCRIPTION="The world's most popular development platform for creating 2D and 3D multiplatform games and interactive experiences."
HOMEPAGE="https://unity3d.co"
SRC_URI="http://beta.unity3d.com/download/${BUILD_HASH}/unity-editor-installer-${MY_PV}.sh"

LICENSE="unity3d"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-util/desktop-file-utils
	x11-misc/xdg-utils
	sys-devel/gcc[multilib]
	virtual/opengl
	virtual/glu
	media-libs/libpng
	dev-lang/mono
	dev-dotnet/gtk-sharp
	sys-apps/fakeroot
"
RDEPEND="${DEPEND}"

src_unpack() {
	yes | fakeroot sh "${DISTDIR}/unity-editor-installer-${MY_PV}.sh" > /dev/null || die "Failed unpacking archive!"
}

S=${WORKDIR}/unity-editor-${MY_PV}

src_install() {
	insinto /opt/${PN}
	doins -r ${S}/Editor
	doins -r ${S}/MonoDevelop

	fperms -R 0755 "/opt/${PN}"
	fperms -R 4755 "/opt/${PN}/Editor/chrome-sandbox"

	newicon unity-editor-icon.png ${PN}.png
	newicon ./Editor/Data/Resources/Mono-gorilla-aqua.100px.png ${PN}-monodevelop.png

	make_wrapper ${PN} ./Editor/Unity /opt/${PN}
	make_wrapper ${PN}-monodevelop ./bin/monodevelop /opt/${PN}/MonoDevelop

	make_desktop_entry ${PN} Unity3d ${PN} "Development;IDE"
	make_desktop_entry ${PN}-monodevelop "Unity3d Monodevelop" ${PN}-monodevelop "Development;IDE"
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
