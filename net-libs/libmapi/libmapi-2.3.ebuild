# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="The OpenChange Project aims to provide a portable Open Source implementation of Microsoft Exchange Server and Exchange protocols"
HOMEPAGE="https://github.com/openchange/"
CODENAME=VULCAN
SRC_URI="https://github.com/openchange/openchange/archive/openchange-${PV}-${CODENAME}.tar.gz"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=net-fs/samba-4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/openchange-openchange-${PV}-${CODENAME}"

src_install() {
    emake DESTDIR="${D}" install
    cd "${D}"
    rm -r openchange AD usr/bin usr/sbin usr/share usr/modules usr/lib64/nagios
}
