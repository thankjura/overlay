# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_7 )

inherit distutils-r1 git-r3

DESCRIPTION="is a node based visual scripting system designed for motion graphics in Blender"
HOMEPAGE="https://github.com/JacquesLucke/animation_nodes"
EGIT_REPO_URI="https://github.com/JacquesLucke/animation_nodes.git"
EGIT_BRANCH="blender2.8"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	media-gfx/blender:=
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	BLENDER_VER=$(blender -v | head -n1 | cut -f2 -d ' ')
	echo "{\"Copy Target\" : \"${D}/usr/share/blender/${BLENDER_VER}/scripts/addons\"}" > conf.json

	mkdir -p ${D%/}/usr/share/blender/${BLENDER_VER}/scripts/addons
	esetup.py build --copy
	python_optimize "${D%/}/usr/share/blender/${BLENDER_VER}/scripts/addons/animation_nodes"
}
