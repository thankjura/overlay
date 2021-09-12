# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker pax-utils

RESTRICT="bindist strip"
DESCRIPTION="Multi-threaded ffmpeg codecs needed for the HTML5 <audio> and <video> tags"
HOMEPAGE="http://www.chromium.org/Home"
LICENSE="BSD"
SLOT="0"
SRC_URI="
	https://mirror.yandex.ru/ubuntu/pool/universe/c/chromium-browser/chromium-codecs-ffmpeg-extra_${PV}-0ubuntu0.18.04.1_i386.deb
"
KEYWORDS="~amd64"
QA_PREBUILT="*"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	strip usr/lib/chromium-browser/libffmpeg.so
	insinto "/opt/yandex/browser-beta"
	doins usr/lib/chromium-browser/libffmpeg.so
}
