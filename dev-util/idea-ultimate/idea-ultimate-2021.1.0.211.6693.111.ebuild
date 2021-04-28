# Copyright 2019 Gianni Bombelli <bombo82@giannibombelli.it>
# Distributed under the terms of the GNU General Public License  as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.

EAPI=7

inherit desktop eutils

DESCRIPTION="A complete toolset for web, mobile and enterprise development"
HOMEPAGE="https://www.jetbrains.com/idea"
VER="$(ver_cut 1-2)"

if [[ "$(ver_cut 3)" == "0" ]]; then
    SRC_URI="http://download.jetbrains.com/idea/ideaIU-$(ver_cut 1-2).tar.gz"
else
    SRC_URI="http://download.jetbrains.com/idea/ideaIU-$(ver_cut 1-3).tar.gz"
fi

LICENSE="|| ( jetbrains_business-3.1 jetbrains_individual-4.1 jetbrains_education-3.2 jetbrains_classroom-4.1 jetbrains_open_source-4.1 )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CC-BY-2.5 CDDL CDDL-1.1 codehaus CPL-1.0 GPL-2 GPL-2-with-classpath-exception GPL-3 ISC LGPL-2.1 LGPL-3 MIT MPL-1.1 MPL-2.0 OFL trilead-ssh yFiles yourkit W3C ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="bindist mirror splitdebug"

S="${WORKDIR}/idea-IU-$(ver_cut 4-6)"

QA_PREBUILT="opt/${PN}/*"

src_prepare() {
	default

	local remove_me=()

	use amd64 || remove_me+=( bin/fsnotifier64 lib/pty4j-native/linux/x86_64)
	use x86 || remove_me+=( bin/fsnotifier lib/pty4j-native/linux/x86)

	rm -rv "${remove_me[@]}" || die
}

src_install() {
	local dir="/opt/${PN}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/idea.sh

	if use amd64; then
		fperms 755 "${dir}"/bin/fsnotifier64
	fi
	if use x86; then
		fperms 755 "${dir}"/bin/fsnotifier
	fi

	fperms 755 "${dir}"/jbr/bin/{jaotc,java,javac,jdb,jjs,jrunscript,keytool,pack200,rmid,rmiregistry,serialver,unpack200}

	make_wrapper "${PN}" "${dir}/bin/idea.sh"
	newicon "bin/idea.svg" "${PN}.svg"
	make_desktop_entry "${PN}" "Idea Ultimate ${VER}" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-${PN}-inotify-watches.conf" || die
}
