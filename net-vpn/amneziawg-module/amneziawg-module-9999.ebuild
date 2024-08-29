# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="Fork of WireGuard with protection against detection by DPI systems"
HOMEPAGE="https://docs.amnezia.org/documentation/amnezia-wg/ https://docs.amnezia.org/documentation/amnezia-wg/"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/amnezia-vpn/amneziawg-linux-kernel-module.git"
	S="${WORKDIR}/${P}/src"
else
	SRC_URI="https://github.com/amnezia-vpn/amneziawg-linux-kernel-module/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/amneziawg-linux-kernel-module-${PV}/src"
fi

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"

LICENSE="GPL-2"
SLOT="0"
IUSE="debug module-src"

CONFIG_CHECK="NET INET NET_UDP_TUNNEL CRYPTO_ALGAPI"

src_compile() {
	ln -sf "${KV_OUT_DIR}" "kernel"
	use debug && MODULES_MAKEARGS+=( CONFIG_WIREGUARD_DEBUG=y )
	emake "${MODULES_MAKEARGS[@]}"
}

src_install() {
	linux_moduleinto net
	linux_domodule amneziawg.ko
	modules_post_process
	use module-src && emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" -C src dkms-install
}

pkg_postinst() {
		linux-mod-r1_pkg_postinst
		local old new
		if [[ $(uname -r) != "${KV_FULL}" ]]; then
			ewarn
			ewarn "You have just built AmneziaWG for kernel ${KV_FULL}, yet the currently running"
			ewarn "kernel is $(uname -r). If you intend to use this AmneziaWG module on the currently"
			ewarn "running machine, you will first need to reboot it into the kernel ${KV_FULL}, for"
			ewarn "which this module was built."
			ewarn
		elif [[ -f /sys/module/amneziawg/version ]] && \
		     old="$(< /sys/module/wireguard/version)" && \
		     new="$(modinfo -F version "${ROOT}/lib/modules/${KV_FULL}/net/amneziawg.ko" 2>/dev/null)" && \
		     [[ $old != "$new" ]]; then
			ewarn
			ewarn "You appear to have just upgraded AmneziaWG from version v$old to v$new."
			ewarn "However, the old version is still running on your system. In order to use the"
			ewarn "new version, you will need to remove the old module and load the new one. As"
			ewarn "root, you can accomplish this with the following commands:"
			ewarn
			ewarn "    # rmmod wireguard"
			ewarn "    # modprobe wireguard"
			ewarn
			ewarn "Do note that doing this will remove current WireGuard interfaces, so you may want"
			ewarn "to gracefully remove them yourself prior."
			ewarn
		fi
}
