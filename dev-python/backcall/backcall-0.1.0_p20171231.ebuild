# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} )
inherit git-r3 distutils-r1


EGIT_REPO_URI="https://github.com/takluyver/backcall"
EGIT_COMMIT="cff13f5"
EGIT_CLONE_TYPE="shallow"

DESCRIPTION="Backwards compatible callback APIs"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

python_prepare_all() {
	eapply -R "${FILESDIR}"/c5567120518c13b69a5b1ab453055e4a5af8485a.patch

	distutils-r1_python_prepare_all
}
