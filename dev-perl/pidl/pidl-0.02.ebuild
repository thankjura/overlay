# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MODULE_AUTHOR="CTRLSOFT"
MODULE_A="Parse-Pidl-${PV}.tar.gz"

inherit perl-app

DESCRIPTION="An IDL compiler written in Perl"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/Parse-Pidl-${PV}
