# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Development kit to build Atlassian plugins"
HOMEPAGE="http://developer.atlassian.com"
SRC_URI="https://sdkrepo.atlassian.com/deb-archive/${PN}_${PV}_all.deb"
LICENSE="Apache-2.0"
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

MAVEN_VERSION="3.2.1"

DEPEND="
	>=dev-java/oracle-jdk-bin-1.8
"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack(){
	unpack "${A}"
	unpack ./data.tar.gz
	rm *.tar.gz debian-binary
}

src_install(){
	insinto /opt/atlassian/${PV}
	doins -r usr/share/${P}/repository || die
	doins -r usr/share/${P}/apache-maven-${MAVEN_VERSION} || die
	exeinto /opt/atlassian/${PV}/bin
	find usr/share/${P}/bin/ -exec doexe '{}' +
	fperms +x //opt/atlassian/${PV}/apache-maven-${MAVEN_VERSION}/bin/mvn
	fperms +x //opt/atlassian/${PV}/apache-maven-${MAVEN_VERSION}/bin/mvn.orig
	fperms +x //opt/atlassian/${PV}/apache-maven-${MAVEN_VERSION}/bin/mvnDebug
	fperms +x //opt/atlassian/${PV}/apache-maven-${MAVEN_VERSION}/bin/mvnyjp
}
