# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_SETUPTOOLS=no
PYTHON_COMPAT=( python3_{9..11} )
BLENDER_VER="3.5"

inherit distutils-r1 git-r3

DESCRIPTION="is a node based visual scripting system designed for motion graphics in Blender"
HOMEPAGE="https://github.com/JacquesLucke/animation_nodes"
EGIT_REPO_URI="https://github.com/JacquesLucke/animation_nodes.git"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	media-gfx/blender:=[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"

src_install() {
	echo "{\"Copy Target\" : \"${D}/usr/share/blender/${BLENDER_VER}/scripts/addons\"}" > conf.json
	mkdir -p ${D%/}/usr/share/blender/${BLENDER_VER}/scripts/addons
	esetup.py build --copy --noversioncheck
	python_optimize "${D%/}/usr/share/blender/${BLENDER_VER}/scripts/addons/animation_nodes"
}
