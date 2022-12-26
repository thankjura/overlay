# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler-1.0.2
	aho-corasick-0.7.20
	anyhow-1.0.68
	atomic_refcell-0.1.8
	autocfg-1.1.0
	base64-0.13.1
	bitflags-1.3.2
	block-0.1.6
	bstr-0.2.17
	byteorder-1.4.3
	cairo-rs-0.16.7
	cairo-sys-rs-0.16.3
	cc-1.0.78
	cfg-expr-0.11.0
	cfg-if-1.0.0
	configparser-3.0.2
	crc32fast-1.3.2
	csv-1.1.6
	csv-core-0.1.10
	field-offset-0.3.4
	flate2-1.0.25
	futures-channel-0.3.25
	futures-core-0.3.25
	futures-executor-0.3.25
	futures-io-0.3.25
	futures-macro-0.3.25
	futures-task-0.3.25
	futures-util-0.3.25
	gdk-pixbuf-0.16.7
	gdk-pixbuf-sys-0.16.3
	gdk4-0.5.4
	gdk4-sys-0.5.4
	getrandom-0.2.8
	gettext-rs-0.7.0
	gettext-sys-0.21.3
	gio-0.16.7
	gio-sys-0.16.3
	glib-0.16.7
	glib-build-tools-0.16.3
	glib-macros-0.16.3
	glib-sys-0.16.3
	gobject-sys-0.16.3
	graphene-rs-0.16.3
	graphene-sys-0.16.3
	gsk4-0.5.4
	gsk4-sys-0.5.4
	gstreamer-0.19.4
	gstreamer-base-0.19.3
	gstreamer-base-sys-0.19.3
	gstreamer-player-0.19.4
	gstreamer-player-sys-0.19.2
	gstreamer-sys-0.19.4
	gstreamer-video-0.19.4
	gstreamer-video-sys-0.19.4
	gtk4-0.5.4
	gtk4-macros-0.5.4
	gtk4-sys-0.5.4
	heck-0.4.0
	itoa-0.4.8
	lazy_static-1.4.0
	libadwaita-0.2.1
	libadwaita-sys-0.2.1
	libc-0.2.138
	locale_config-0.3.0
	lofty-0.9.0
	lofty_attr-0.4.0
	log-0.4.17
	malloc_buf-0.0.6
	md5-0.7.0
	memchr-2.5.0
	memoffset-0.6.5
	miniz_oxide-0.6.2
	muldiv-1.0.1
	num-integer-0.1.45
	num-rational-0.4.1
	num-traits-0.2.15
	objc-0.2.7
	objc-foundation-0.1.1
	objc_id-0.1.1
	ogg_pager-0.3.2
	once_cell-1.16.0
	option-operations-0.5.0
	pango-0.16.5
	pango-sys-0.16.3
	paste-1.0.11
	pest-2.5.1
	pin-project-lite-0.2.9
	pin-utils-0.1.0
	pkg-config-0.3.26
	ppv-lite86-0.2.17
	pretty-hex-0.3.0
	proc-macro-crate-1.2.1
	proc-macro-error-1.0.4
	proc-macro-error-attr-1.0.4
	proc-macro2-1.0.49
	quote-1.0.23
	rand-0.8.5
	rand_chacha-0.3.1
	rand_core-0.6.4
	regex-1.7.0
	regex-automata-0.1.10
	regex-syntax-0.6.28
	rustc_version-0.3.3
	ryu-1.0.12
	semver-0.11.0
	semver-parser-0.10.2
	serde-1.0.151
	serde_derive-1.0.151
	slab-0.4.7
	smallvec-1.10.0
	syn-1.0.107
	system-deps-6.0.3
	temp-dir-0.1.11
	thiserror-1.0.38
	thiserror-impl-1.0.38
	toml-0.5.10
	ucd-trie-0.1.5
	unicode-ident-1.0.6
	uuid-1.2.2
	uuid-macro-internal-1.2.2
	version-compare-0.1.1
	version_check-0.9.4
	wasi-0.11.0+wasi-snapshot-preview1
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo gnome2-utils meson xdg

DESCRIPTION="Music player for Gnome"
HOMEPAGE="https://github.com/thankjura/beat-audio-player-rs"

SRC_URI="https://github.com/thankjura/beat-audio-player-rs/archive/refs/tags/${PV}.tar.gz
		$(cargo_crate_uris)"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

KEYWORDS="amd64 ~arm64 x86"

DEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.50:2
	>=dev-libs/gobject-introspection-1.54:=
	>=gui-libs/gtk-4.8
	>=gui-libs/libadwaita-1.2
	x11-libs/cairo
	media-libs/gstreamer
"
S=${WORKDIR}/beat-audio-player-rs-${PV}
BUILD_DIR=${WORKDIR}/${P}
ECARGO_HOME=${BUILD_DIR}/cargo-home

#src_prepare() {
#	cargo_src_prepare
#	meson_src_prepare
#}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"
	echo ${ECARGO_HOME}
#	cargo build
	meson_src_compile
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
