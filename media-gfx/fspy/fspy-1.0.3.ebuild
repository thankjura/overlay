# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8} )

inherit eutils desktop python-single-r1

AV=${PV}
DESCRIPTION="Open source still image camera matching"
HOMEPAGE="https://fspy.io/"
SRC_URI="https://github.com/stuffmatic/fSpy/archive/v${PV}.tar.gz -> ${P}.tar.gz
		blender? ( https://github.com/stuffmatic/fSpy-Blender/archive/v${PV}.tar.gz -> ${PN}-blender-${AV}.tar.gz )
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="network-sandbox"
IUSE="+blender"

DEPEND="
	sys-apps/yarn
"
RDEPEND="
	${DEPEND}
	blender? ( media-gfx/blender:=[${PYTHON_SINGLE_USEDEP}] )
"

S=${WORKDIR}/fSpy-${PV}

src_prepare() {
	eapply_user
	yarn || die
	sed -i s/"electron-builder -mwl"/"electron-builder"/ package.json
}

src_compile() {
	yarn --offline dist || die
}

src_install() {
	mkdir -p ${D}/usr/lib64/${PN}
	cp -a dist/linux-unpacked/* ${D}/usr/lib64/${PN}
	make_wrapper ${PN} /usr/lib64/${PN}/${PN} /usr/lib64/${PN} /usr/lib64/${PN}
	make_desktop_entry ${PN} fSpy ${PN} "Graphics"

	if use blender; then
		cd ${WORKDIR}/fSpy-Blender-${AV}/${PN}_blender
		BV=$(blender -v | head -n1 | cut -f2 -d ' ')
		mkdir -p ${D}/usr/share/blender/${BV}/scripts/addons/fspy
		cp -a * ${D}/usr/share/blender/${BV}/scripts/addons/fspy
		python_optimize "${D%/}/usr/share/blender/${BV}/scripts/addons/fspy"
	fi
}
