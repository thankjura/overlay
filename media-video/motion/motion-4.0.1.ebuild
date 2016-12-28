# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils readme.gentoo user systemd

GITHUB_USER="Motion-Project"

DESCRIPTION="A software motion detector"
HOMEPAGE="https://motion-project.github.io/"
SRC_URI="https://github.com/Motion-Project/${PN}/archive/release-4.0.1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ppc x86"
IUSE="ffmpeg libav mysql postgres +v4l"

RDEPEND="
	sys-libs/zlib
	virtual/jpeg
	ffmpeg? (
		libav? ( media-video/libav:= )
		!libav? ( media-video/ffmpeg:0= )
	)
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql )
"
# note: libv4l is only in dependencies for the libv4l1-videodev.h header file
# used by the -workaround-v4l1_deprecation.patch.
DEPEND="${RDEPEND}
	v4l? ( virtual/os-headers media-libs/libv4l )
"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="You need to setup /etc/motion.conf before running
motion for the first time.
You can install motion detection as a service, use:
rc-update add motion default
"

pkg_setup() {
	enewuser motion -1 -1 -1 video
}

S=${WORKDIR}/motion-release-${PV}

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		$(use_with v4l) \
		$(use_with ffmpeg) \
		$(use_with mysql) \
		$(use_with postgres pgsql) \
		--without-optimizecpu
}

src_install() {
	emake \
		DESTDIR="${D}" \
		DOC='CHANGELOG CODE_STANDARD CREDITS FAQ' \
		docdir=/usr/share/doc/${PF} \
		examplesdir=/usr/share/doc/${PF}/examples \
		install

	dohtml *.html

	newinitd "${FILESDIR}"/motion.initd-r2 motion
	newconfd "${FILESDIR}"/motion.confd motion
	systemd_dounit "${S}"/motion.service
	readme.gentoo_create_doc
}
