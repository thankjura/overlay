# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils gnome2-utils pax-utils unpacker

DESCRIPTION="P2P Internet Telephony (VoiceIP) client"
HOMEPAGE="http://www.skype.com/"
SRC_URI="https://repo.skype.com/latest/skypeforlinux-64-alpha.deb"

LICENSE="skype-4.0.0.7-copyright BSD MIT RSA W3C regexp-UofT no-source-code"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	virtual/ttf-fonts
	dev-qt/qtcore:4[abi_x86_32(-)]
	dev-qt/qtdbus:4[abi_x86_32(-)]
	dev-qt/qtgui:4[accessibility,abi_x86_32(-)]
	dev-qt/qtwebkit:4[-exceptions,abi_x86_32(-)]
	media-libs/alsa-lib[abi_x86_32(-)]
	x11-libs/libX11[abi_x86_32(-)]
	x11-libs/libXext[abi_x86_32(-)]
	x11-libs/libXScrnSaver[abi_x86_32(-)]
	x11-libs/libXv[abi_x86_32(-)]
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
