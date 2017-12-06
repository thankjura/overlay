# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_6 )

inherit git-r3 gnome2-utils python-single-r1

DESCRIPTION="Parametrical modeling program for creating human bodies"
HOMEPAGE="http://www.makehuman.org"
EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman.git"
EGIT_BRANCH="AranuvirQt5"
EGIT_COMMIT=a175c9b59c55318ef2c2e573ecd0d0282c594e6f

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/pyopengl[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"

B=${WORKDIR}/build
src_prepare() {	
	ln -sf ${S}/blendertools/makeclothes ${S}/blendertools/makewalk/makeclothes
	ln -sf ${S}/blendertools/maketarget ${S}/blendertools/makewalk/maketarget
	eapply_user
}

src_compile() {
	./buildscripts/build_prepare.py . ${WORKDIR}/build
	python_optimize ${B}/makehuman
}

src_install() {
	install -d -m755 "${D}/opt/"
	cp -a "${B}/makehuman" "${D}/opt/"
	doicon ${B}/makehuman/icons/makehuman.png
	install -D -m755 "${FILESDIR}/${PN}.sh" "${D}/usr/bin/${PN}"
	make_desktop_entry ${PN} MakeHuman ${PN}.png Graphics

	if VER="/usr/share/blender/*"; then
	    insinto ${VER}/scripts/addons/
	    doins -r ${B}/makehuman/blendertools/*
	fi
}
