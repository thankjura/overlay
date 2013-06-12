# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit flag-o-matic

WANT_AUTOMAKE=1.12

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="http://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"

LICENSE="LGPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="debug debug-malloc +deprecated +networking nls +regex +threads"

RDEPEND="
	app-admin/eselect-guile
	>=dev-libs/boehm-gc-7.0[threads?]
	dev-libs/gmp
	dev-libs/libffi
	>=dev-libs/libunistring-0.9.3
	sys-devel/gettext
	>=sys-devel/libtool-1.5.6"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

SLOT="2"
MAJOR="2.0"

src_configure() {
	# see bug #178499
	filter-flags -ftree-vectorize

	#will fail for me if posix is disabled or without modules -- hkBst
	econf \
		--program-suffix="-${MAJOR}" \
		--infodir="${EPREFIX}"/usr/share/info/guile-${MAJOR} \
		--disable-error-on-warning \
		--disable-static \
		--enable-posix \
		$(use_enable networking) \
		$(use_enable regex) \
		$(use_enable deprecated) \
		$(use_enable nls) \
		--disable-rpath \
		$(use_enable debug-malloc) \
		$(use_enable debug guile-debug) \
		$(use_with threads) \
		--with-modules
}

src_compile()  {
	emake || die "make failed"
}

src_install() {
	einstall infodir="${ED}"/usr/share/info/guile-${MAJOR} || die "install failed"

	# Maybe there is a proper way to do this? Symlink handled by eselect
	mv "${ED}"/usr/share/aclocal/guile.m4 "${ED}"/usr/share/aclocal/guile-${MAJOR}.m4 || die "rename of guile.m4 failed"

	dodoc AUTHORS ChangeLog GUILE-VERSION HACKING NEWS README THANKS || die

	# necessary for registering slib, see bug 206896
	keepdir /usr/share/guile/site
}

pkg_postinst() {
	[ "${EROOT}" == "/" ] && pkg_config
	eselect guile update ifunset
}

pkg_postrm() {
	eselect guile update ifunset
}

pkg_config() {
	if has_version dev-scheme/slib; then
		einfo "Registering slib with guile"
		install_slib_for_guile
	fi
}

_pkg_prerm() {
	rm -f "${EROOT}"/usr/share/guile/site/slibcat
}
