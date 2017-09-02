# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

HASH="3d48cb0c28be"

DESCRIPTION="The fast and accurate Genesis emulator"
HOMEPAGE="https://www.retrodev.com/blastem/"
SRC_URI="https://www.retrodev.com/repos/blastem/archive/${HASH}.tar.gz -> ${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	media-libs/libsdl2
	media-libs/glew
	dev-python/pillow
	media-gfx/xcftools
	dev-lang/vasm
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}-${HASH}

src_prepare() {
	eapply ${FILESDIR}/${P}-fix-python.patch || die
	eapply_user
}

src_compile() {
	emake blastem
	emake menu.bin
}

src_install() {
	insinto /opt/${PN}
	insopts -m 644 -g games
	doins -r shaders default.cfg rom.db gamecontrollerdb.txt
	insopts -m 755 -g games
	doins blastem menu.bin
	
	dosym /opt/${PN}/blastem /usr/games/bin/${PN}
	
	xcf2png icons/windows.xcf > ${PN}.png
	
	dodoc CHANGELOG COPYING README
	
	doicon -s 48 ${PN}.png
	make_desktop_entry blastem "BlastEM"
}
