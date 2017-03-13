# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=5

inherit eutils games

DESCRIPTION="First person shooter from 3D Realms"
HOMEPAGE="http://icculus.org/prey/ http://www.3drealms.com/prey/"
UPSTREAM_PV=${PV:4:2}${PV:6}${PV::4}
SRC_URI="http://icculus.org/prey/downloads/prey-installer-${UPSTREAM_PV}.bin"

LICENSE="PREY"
SLOT="0"
KEYWORDS="~amd64"
IUSE="dedicated openal opengl"
PROPERTIES="interactive"

# mirror restriction might be needed as well
RESTRICT="strip"

UIDEPEND="virtual/opengl
	openal? ( media-libs/openal[abi_x86_32] )
	media-libs/libsdl[abi_x86_32]"
DEPEND="app-arch/unzip
	sys-libs/libstdc++-v3"
RDEPEND="opengl? ( ${UIDEPEND} )
	!dedicated? ( !opengl? ( ${UIDEPEND} ) )"

S=${WORKDIR}

GAMES_CHECK_LICENSE="yes"
dir=${GAMES_PREFIX_OPT}/${PN}
Ddir=${D}/${dir}

QA_TEXTRELS="${dir:1}/pb/pbcl.so
	${dir:1}/pb/pbag.so
	${dir:1}/pb/pbsv.so"

pkg_setup() {
	games_pkg_setup

	# This is a binary x86 package => ABI=x86
	has_multilib_profile && ABI="x86"
}

src_unpack() {
	unzip "${DISTDIR}/prey-installer-${UPSTREAM_PV}.bin"
}

src_install() {
	# installation of files that goes to ${dir}
	insinto "${dir}"
	exeinto "${dir}"

	# >common (both dedicated and graphical client) files
	doins -r data/punkbuster-linux-x86/pb || die "doins punkbuster"

	# >graphical game client files
	if use opengl || ! use dedicated ; then
		doexe data/prey-linux-x86/prey{,.x86} \
			data/prey-linux-x86/libNvidiaVidMemTest.so || \
			die "doexe client executables"

		dosym "/usr/$(get_libdir)/libSDL-1.2.so.0" "${dir}" || \
			die "dosym libSDL"

		if use openal; then
			dosym "/usr/$(get_libdir)/libopenal.so" "${dir}/openal.so" || \
				die "dosym libopenal"
		fi

		newicon data/prey-linux-data/prey.png ${PN}.png

		games_make_wrapper ${PN} ./prey "${dir}" "${dir}"
		make_desktop_entry ${PN} "Prey"
	fi

	# >dedicated server files
	if use dedicated ; then
		doexe data/prey-linux-x86/preyded{,.x86} || \
			die "doexe dedicated executables"

		games_make_wrapper ${PN}-ded ./preyded "${dir}" "${dir}"
	fi

	# installation of files that goes to ${dir}/base
	insinto "${dir}/base"
	exeinto "${dir}/base"
	doexe data/prey-linux-x86/base/gamex86.so || die "doexe base/gamex86.so"
	doins -r data/prey-linux-data/base/* || die "doins data"

	# documentation files
	dodoc data/prey_readme.txt || die "dodoc readme"

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	elog "You need to copy pak000.pk4 through pak004.pk4 from either your"
	elog "installation media or your hard drive to ${dir}/base before"
	elog "running the game."
	echo
}
