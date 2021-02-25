# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools eutils flag-o-matic

DESCRIPTION="A Gens fork which aims to clean up the source code and combine features from other forks"
HOMEPAGE="http://info.sonicretro.org/Gens/GS"
SRC_URI="http://www.soniccenter.org/gerbilsoft/gens/r7/${PN}-r${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opengl"

RDEPEND="opengl? (
		virtual/opengl[abi_x86_32]
	)

	>=media-libs/libsdl-1.2[opengl?,abi_x86_32]
	x11-libs/gtk+:2[abi_x86_32]

	!games-emulation/gens
"
DEPEND="${RDEPEND}
	>=dev-lang/nasm-0.98
"

S="${WORKDIR}/${PN}-r${PV}"

DOCS=( "ChangeLog.txt" )

src_prepare() {
	sed -i '1i#define OF(x) x' src/extlib/minizip/ioapi.h

	eapply "${FILESDIR}/gtk_build_fix.patch"
	eapply "${FILESDIR}/amd64.patch"
	eapply "${FILESDIR}/libtool.patch"

	sed -i 's/Application;//' xdg/gens.desktop

	append-ldflags -Wl,-z,noexecstack
	eautoreconf

	eapply_user
}

src_configure() {
	use amd64 && multilib_toolchain_setup x86

	econf $(use_with opengl) \
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
}

src_install() {
	emake DESTDIR="${D}" install
	einstalldocs
}
