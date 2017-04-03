# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils distutils-r1

DESCRIPTION="Mail nagger for gnome-shell (port of popper for unity)"
HOMEPAGE="http://launchpad.net/mailnag"
SRC_URI="https://github.com/pulb/mailnag/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/pygobject:3
		dev-python/gnome-keyring-python
		${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i -e 's|./mailnag|mailnag|' ${S}/mailnag_config
}

