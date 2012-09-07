# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gnome-contacts/gnome-contacts-3.4.1.ebuild,v 1.1 2012/05/14 01:39:48 tetromino Exp $

EAPI="4"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="GObject based library for accessing the Secret Service API."

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	>=x11-libs/gtk+-3.4:3"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README"
	# We do not need valac when building from pre-generated C sources,
	# but configure checks for it anyway
}
