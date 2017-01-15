# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="6"
inherit multilib toolchain-funcs flag-o-matic git-r3 eutils

DESCRIPTION="DSSI wrapper plugin for Windows VSTs"
HOMEPAGE="https://github.com/falkTX/dssi-vst"
EGIT_REPO_URI="https://github.com/falkTX/dssi-vst.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=media-libs/dssi-0.9.0
	media-libs/ladspa-sdk
	>=media-libs/liblo-0.12
	media-libs/alsa-lib
	media-sound/jack-audio-connection-kit
	app-emulation/wine"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	eapply "${FILESDIR}/${PN}-Makefile.patch"
}

src_compile(){
	tc-export CXX
	emake || "die emake failed"
}

src_install() {
	make \
		PREFIX="${D}/usr" \
		DSSIDIR="${D}/usr/$(get_libdir)/dssi" \
		LADSPADIR="${D}/usr/$(get_libdir)/ladspa" install \
		|| die "install failed"
	dodoc README
}
