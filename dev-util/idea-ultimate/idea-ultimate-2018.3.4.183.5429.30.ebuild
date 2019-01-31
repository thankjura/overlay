# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
inherit eutils versionator

RDEPEND=">=virtual/jdk-1.8"

RESTRICT="strip mirror"
QA_TEXTRELS="opt/${P}/bin/libbreakgen.so"

DESCRIPTION="IntelliJ IDEA is an intelligent Java IDE"
HOMEPAGE="https://jetbrains.com/idea/"
MY_PN="idea"
VER=($(get_all_version_components))
if [[ "${VER[4]}" == "0" ]]; then
    SRC_URI="http://download.jetbrains.com/${MY_PN}/${MY_PN}IU-$(get_version_component_range 1-2)-no-jdk.tar.gz"
else
    SRC_URI="http://download.jetbrains.com/${MY_PN}/${MY_PN}IU-$(get_version_component_range 1-3)-no-jdk.tar.gz"
fi

SLOT="0"
LICENSE="IntelliJ-IDEA"
IUSE=""
KEYWORDS="~x86 ~amd64"
MY_PV="$(get_version_component_range 4-5)"
SHORT_PV="$(get_version_component_range 1-2)"

S="${WORKDIR}/${MY_PN}-IU-${MY_PV}"

src_unpack() {
	unpack ${A}
	mv ${WORKDIR}/${MY_PN}-IU-* ${WORKDIR}/${MY_PN}-IU-${MY_PV}
}

src_install() {
	local dir="/opt/${MY_PN}-${SHORT_PV}"
	local exe="${PN}"

	# config files
	insinto "/etc/idea"

	mv bin/idea.properties bin/idea-${SLOT}.properties
	doins bin/idea-${SLOT}.properties
	rm bin/idea-${SLOT}.properties

	case $ARCH in
		amd64|ppc64)
			cat bin/idea64.vmoptions > bin/idea.vmoptions
			rm bin/idea64.vmoptions
			;;
	esac

	mv bin/idea.vmoptions bin/idea-${SLOT}.vmoptions
	doins bin/idea-${SLOT}.vmoptions
	rm bin/idea-${SLOT}.vmoptions

	ln -s /etc/idea/idea-${SLOT}.properties bin/idea.properties

	rm bin/fsnotifier-arm
	rm -rf plugins/tfsIntegration/lib/native/linux/ppc
	rm -rf plugins/tfsIntegration/lib/native/solaris

	# idea itself
	insinto "${dir}"
	doins -r *

	fperms 755 "${dir}/bin/${MY_PN}.sh"
	fperms 755 "${dir}/bin/fsnotifier"
	fperms 755 "${dir}/bin/fsnotifier64"

	newicon "bin/${MY_PN}.png" "${exe}.png"
	make_wrapper "${exe}" "/opt/${MY_PN}-${SHORT_PV}/bin/${MY_PN}.sh"
	make_desktop_entry ${exe} "IntelliJ IDEA ${SHORT_PV}" "${exe}" "Development;IDE"
}
