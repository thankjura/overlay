# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/pitivi/pitivi-0.14.1.ebuild,v 1.1 2011/07/24 17:02:38 eva Exp $

EAPI="3"
GCONF_DEBUG="no"
PYTHON_DEPEND="2:2.5"

inherit gnome2 python eutils virtualx

DESCRIPTION="A non-linear video editor using the GStreamer multimedia framework"
HOMEPAGE="http://www.pitivi.org"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# Test fails by not finding audiosink ?
RESTRICT="test"

# gst-plugins-good-0.10.24 needed for prefer-passthrough property
# gst-plugins-base-0.10.31 needed for add-borders property, and decodebin2
COMMON_DEPEND="
	dev-python/pycairo

	>=media-libs/gstreamer-0.10.28:0.10
	>=dev-python/gst-python-0.10.19
	media-libs/gnonlin"
RDEPEND="${COMMON_DEPEND}
	dev-python/dbus-python
	dev-python/pygoocanvas
	dev-python/pyxdg"

DEPEND="${RDEPEND}
	dev-python/setuptools
	sys-devel/gettext
	>=dev-util/intltool-0.35.5"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS RELEASE"
	python_set_active_version 2
}

src_prepare() {
	gnome2_src_prepare

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

src_configure() {
	addpredict $(unset HOME; echo ~)/.gconf
	addpredict $(unset HOME; echo ~)/.gconfd
	addpredict $(unset HOME; echo ~)/.gstreamer-0.10

	gnome2_src_configure
}

src_test() {
	export XDG_CONFIG_HOME="${WORKDIR}/.config"
	export XDG_DATA_HOME="${WORKDIR}/.local"
	# Force Xvfb to be used
	unset DISPLAY
	unset DBUS_SESSION_BUS_ADDRESS
	export PITIVI_TOP_LEVEL_DIR="${S}"
	Xemake check || die "tests failed"
}

src_install() {
	gnome2_src_install
	python_convert_shebangs -r 2 "${D}"
}

pkg_postinst() {
	gnome2_pkg_postinst
	python_mod_optimize "/usr/$(get_libdir)/${PN}/python/${PN}"
}

pkg_postrm() {
	gnome2_pkg_postrm
	python_mod_cleanup "/usr/$(get_libdir)/${PN}/python/${PN}"
}
