# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit gnome2-utils python-single-r1

DESCRIPTION="Parametrical modeling program for creating human bodies"
HOMEPAGE="http://www.makehuman.org"
SRC_URI="https://bitbucket.org/MakeHuman/makehuman/get/${PV}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/PyQt4[${PYTHON_USEDEP}]
	dev-python/pyopengl[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/MakeHuman-makehuman-8bd47bfc28a1

src_prepare() {	
	rm ${S}/makehuman/makehuman
	eapply_user
}

src_compile() {
	python_fix_shebang makehuman
	python_optimize makehuman
}

src_install() {
	install -d -m755 "${D}/opt/"
	cp -a "${S}/makehuman" "${D}/opt/"
	doicon ${S}/makehuman/icons/makehuman.png
	install -D -m755 "${FILESDIR}/${PN}.sh" "${D}/usr/bin/${PN}"
	make_desktop_entry ${PN} MakeHuman ${PN}.png Graphics

	if VER="/usr/share/blender/*"; then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/blendertools/*
	fi
}
