# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=(python{2_5,2_6,2_7})

inherit distutils git-2 eutils

EGIT_REPO_URI="git://github.com/nvbn/everpad.git"
EGIT_MASTER="develop"

DESCRIPTION="Evernote client well integrated with linux desktop"
HOMEPAGE="https://github.com/nvbn/everpad"
SRC_URI=""

LICENSE="X11"
SLOT="0"
IUSE="test"

KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}
        dev-python/beautifulsoup
        dev-python/html2text
        dev-python/httplib2
        dev-python/keyring
        dev-python/py-oauth2
        dev-python/regex
        dev-python/sqlalchemy
        dev-python/dbus-python
        dev-python/setuptools
        dev-python/pyside[webkit]
	sys-apps/file[python]
        "

python_test() {
        esetup.py test
}

src_prepare() {
        distutils_src_prepare
        epatch "${FILESDIR}/${P}-content.py.patch"
	epatch "${FILESDIR}/${P}-everpad.desktop.patch"
}

python_install() {
	distutils_src_install
        delete_tests() {
                rm -fr "${ED}$(python_get_sitedir)/everpad/tests"
        }
        python_execute_function -q delete_tests
}
