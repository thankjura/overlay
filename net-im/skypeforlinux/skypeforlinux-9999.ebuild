# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils gnome2-utils pax-utils unpacker

DESCRIPTION="P2P Internet Telephony (VoiceIP) client"
HOMEPAGE="http://www.skype.com/"
SRC_URI="https://repo.skype.com/latest/skypeforlinux-64-alpha.deb"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	dev-libs/atk
	x11-libs/cairo
	net-print/cups
	sys-apps/dbus
	dev-libs/expat
	gnome-base/gconf
	gnome-base/libgnome-keyring
"

S=${WORKDIR}

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	mv * "${D}" || die
	fperms 755 /usr/bin/skypeforlinux
	fperms 755 /usr/share/skypeforlinux/skypeforlinux
}

pkg_postrm() {
	gnome2_icon_cache_update
}
