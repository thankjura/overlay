# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit eutils desktop

SLOT="0"
PV_STRING="$(ver_cut 4-6)"
MY_PV="$(ver_cut 1-2)"
MY_PN="idea"
# Using the most recent Jetbrains Runtime binaries available at the time of writing
# As the exact bundled versions ( jre 11 build 159.30 and jre 8 build 1483.39 ) aren't
# available separately
JRE11_BASE="11_0_12"
JRE11_VER="1649.1"

# distinguish settings for official stable releases and EAP-version releases
if [[ "$(ver_cut 7)"x = "prex" ]]
then
	# upstream EAP
	KEYWORDS=""
	SRC_URI="https://download.jetbrains.com/idea/${MY_PN}IU-${PV_STRING}.tar.gz"
else
	# upstream stable
	KEYWORDS="~amd64"
	SRC_URI="https://download.jetbrains.com/idea/${MY_PN}IU-${MY_PV}-no-jbr.tar.gz -> ${MY_PN}IU-${PV_STRING}.tar.gz
		https://cache-redirector.jetbrains.com/intellij-jbr/jbrsdk-${JRE11_BASE}-linux-x64-b${JRE11_VER}.tar.gz -> jbr-${JRE11_BASE}-linux-x64-b${JRE11_VER}.tar.gz"
fi

DESCRIPTION="A complete toolset for web, mobile and enterprise development"
HOMEPAGE="https://www.jetbrains.com/idea"

LICENSE="IDEA
	|| ( IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )"

DEPEND="!dev-util/${PN}:14
	!dev-util/${PN}:15"
RDEPEND="${DEPEND}
	>=virtual/jdk-1.7:*
	dev-java/jansi-native
	dev-libs/libdbusmenu
	dev-util/lldb"
BDEPEND="dev-util/patchelf"
RESTRICT="splitdebug"
S="${WORKDIR}/${MY_PN}-IU-${PV_STRING}"

QA_PREBUILT="opt/${PN}-${MY_PV}/*"

src_unpack() {
	default_src_unpack
	mkdir jre64 && cd jre64 && unpack jbr-${JRE11_BASE}-linux-x64-b${JRE11_VER}.tar.gz
}

src_prepare() {
	JRE_DIR=jre64

	PLUGIN_DIR="${S}/${JRE_DIR}/lib/"

	rm -vf ${PLUGIN_DIR}/libavplugin*
	rm -vf "${S}"/plugins/maven/lib/maven3/lib/jansi-native/*/libjansi*
	rm -vrf "${S}"/lib/pty4j-native/linux/ppc64le
	rm -vf "${S}"/bin/libdbm64*

	if [[ -d "${S}"/"${JRE_DIR}" ]]; then
		for file in "${PLUGIN_DIR}"/{libfxplugins.so,libjfxmedia.so}
		do
			if [[ -f "$file" ]]; then
			  patchelf --set-rpath '$ORIGIN' $file || die
			fi
		done
	fi

	patchelf --replace-needed liblldb.so liblldb.so.9 "${S}"/plugins/Kotlin/bin/linux/LLDBFrontend || die "Unable to patch LLDBFrontend for lldb"

	sed -i \
		-e "\$a\\\\" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$a# Disable automatic updates as these are handled through Gentoo's" \
		-e "\$a# package manager. See bug #704494" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$aide.no.platform.update=Gentoo"  bin/idea.properties

	eapply_user
}

src_install() {
	local dir="/opt/${PN}-${MY_PV}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/{format.sh,idea.sh,inspect.sh,printenv.py,restart.py,fsnotifier}
	JRE_DIR=jre64
	JRE_BINARIES="jaotc java javapackager jjs jrunscript keytool pack200 rmid rmiregistry unpack200"
	if [[ -d ${JRE_DIR} ]]; then
		for jrebin in $JRE_BINARIES; do
			fperms 755 "${dir}"/"${JRE_DIR}"/bin/"${jrebin}"
		done
	fi

	make_wrapper "${PN}" "${dir}/bin/${MY_PN}.sh"
	newicon "bin/${MY_PN}.png" "${PN}.png"
	make_desktop_entry "${PN}" "IntelliJ Idea Ultimate" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	mkdir -p "${D}/etc/sysctl.d/" || die
	echo "fs.inotify.max_user_watches = 524288" > "${D}/etc/sysctl.d/30-idea-inotify-watches.conf" || die
}
