EAPI=7
PYTHON_COMPAT=( python3_{6,7} )
DESCRIPTION="Graphical application to configure Logitech Wheels"
HOMEPAGE="https://github.com/berarma/oversteer"
SRC_URI="https://github.com/berarma/oversteer/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"

BDEPEND="dev-util/meson"

RDEPEND="dev-python/pygobject
		 dev-python/pyudev
		 dev-python/python-evdev
		 dev-python/pyxdg
		 sys-devel/gettext
		 dev-libs/appstream-glib
		 dev-util/desktop-file-utils
		 x11-libs/gtk+"

src_prepare() {
	eapply_user
	sed -i 's/Utility;//' data/org.berarma.Oversteer.desktop.in
}

src_compile() {
	meson build --prefix="/usr"
	ninja -C build
}

src_install() {
	DESTDIR="${D}" ninja -C build install
}
 
