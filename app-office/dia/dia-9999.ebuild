# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )

inherit python-single-r1 gnome2-utils git-r3 meson

DESCRIPTION="A GTK+ based diagram creation program"
HOMEPAGE="http://live.gnome.org/Dia"
EGIT_REPO_URI="https://gitlab.gnome.org/GNOME/dia.git"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	dev-libs/libxslt
	x11-libs/gtk+:2
	media-libs/freetype
	>=dev-libs/glib-2.58
	>=dev-libs/libxml2-2.9.4
	sys-libs/zlib
	x11-libs/cairo
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default
	sed -i 's_#!/usr/bin/env python3_#!/usr/bin/env python2_' build-aux/post-install.py
}

