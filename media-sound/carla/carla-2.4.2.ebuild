# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9,10} )
inherit python-single-r1 toolchain-funcs xdg-utils

DESCRIPTION="Full featured audio plugin host supporting many audio drivers and plugin formats"
HOMEPAGE="https://kx.studio/Applications:Carla"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/falkTX/${PN}"
else
	SRC_URI="https://github.com/falkTX/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${P/c/C}"
fi

LICENSE="GPL-2+ LGPL-3"
SLOT="0"
IUSE="+X alsa +gtk gtk2 +juce lto osc pulseaudio +qt5 rdf sf2 +sndfile"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	juce? ( X )
"

RDEPEND="
	${PYTHON_DEPS}
	X? (
		juce? (
			media-libs/freetype:2
			x11-libs/libXcursor
			x11-libs/libXext
		)
		x11-base/xorg-server
	)
	alsa? ( media-libs/alsa-lib )
	gtk2? ( x11-libs/gtk+:2 )
	gtk? ( x11-libs/gtk+:3 )
	osc? (
		$(python_gen_cond_dep 'dev-python/pyliblo[${PYTHON_USEDEP}]')
		media-libs/liblo
	)
	pulseaudio? ( media-sound/pulseaudio )
	qt5? ( $(python_gen_cond_dep 'dev-python/PyQt5[gui,svg,widgets,${PYTHON_USEDEP}]') )
	rdf? ( dev-python/rdflib )
	sf2? ( media-sound/fluidsynth )
	sndfile? ( media-libs/libsndfile )
	sys-apps/file
	virtual/jack
"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/types.patch" )

src_prepare() {
	sed -i -e "3s|=.*|=${PYTHON}|; 4,7d" \
		data/carla \
		data/carla-bridge-lv2-modgui \
		data/carla-control \
		data/carla-database \
		data/carla-jack-multi \
		data/carla-jack-single \
		data/carla-patchbay \
		data/carla-rack \
		data/carla-settings || die "sed failed"

	default
}

src_compile() {
	myemakeargs=(
		CLANG=$(tc-is-clang && echo true || echo false)
		HAVE_ALSA=$(usex alsa true false)
		HAVE_FLUIDSYNTH=$(usex sf2 true false)
		HAVE_GTK2=$(usex gtk2 true false)
		HAVE_GTK3=$(usex gtk true false)
		HAVE_LIBLO=$(usex osc true false)
		HAVE_PULSEAUDIO=$(usex pulseaudio true false)
		HAVE_PYQT=$(usex qt5 true false)
		HAVE_QT5=$(usex qt5 true false)
		HAVE_SNDFILE=$(usex sndfile true false)
		HAVE_X11=$(usex X true false)
		LIBDIR="/usr/$(get_libdir)"
		SKIP_STRIPPING=true
		USING_JUCE=$(usex juce true false)
		WITH_LTO=$(usex lto true false)
	)

	emake PREFIX="${EPREFIX}/usr" "${myemakeargs[@]}" features
	emake PREFIX="${EPREFIX}/usr" "${myemakeargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" "${myemakeargs[@]}" install
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}
