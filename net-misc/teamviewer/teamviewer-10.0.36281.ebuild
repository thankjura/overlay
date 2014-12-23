# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils gnome2-utils systemd unpacker

# Major version
MV=${PV/\.*}
DESCRIPTION="All-In-One Solution for Remote Access and Support over the Internet"
HOMEPAGE="http://www.teamviewer.com"
SRC_URI="http://www.teamviewer.com/download/version_${MV}x/teamviewer_linux.deb -> ${P}.deb"

LICENSE="TeamViewer !system-wine? ( LGPL-2.1 )"
SLOT=0
KEYWORDS="~*"
IUSE="system-wine"

RESTRICT="mirror"

RDEPEND="
	app-shells/bash
	x11-misc/xdg-utils
	!system-wine? (
		amd64? (
			app-emulation/emul-linux-x86-baselibs
			app-emulation/emul-linux-x86-soundlibs
			|| (
				(
					x11-libs/libSM[abi_x86_32]
					x11-libs/libX11[abi_x86_32]
					x11-libs/libXau[abi_x86_32]
					x11-libs/libXdamage[abi_x86_32]
					x11-libs/libXext[abi_x86_32]
					x11-libs/libXfixes[abi_x86_32]
					x11-libs/libXtst[abi_x86_32]
				)
				app-emulation/emul-linux-x86-xlibs
			)
		)
		x86? (
			sys-libs/zlib
			x11-libs/libSM
			x11-libs/libX11
			x11-libs/libXau
			x11-libs/libXdamage
			x11-libs/libXext
			x11-libs/libXfixes
			x11-libs/libXtst
		)
	)
	system-wine? ( app-emulation/wine )"

QA_PREBUILT="opt/${PN}/*"

S=${WORKDIR}/opt/${PN}/tv_bin

make_winewrapper() {
	cat << EOF > "${T}/${PN}"
#!/bin/sh
export WINEDLLPATH=/opt/${PN}
exec wine "/opt/${PN}/TeamViewer.exe" "\$@"
EOF
	chmod go+rx "${T}/${PN}"
	exeinto /opt/bin
	doexe "${T}/${PN}"
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-9.0.30203-gentoo.patch

	sed \
		-e "s#@TVV@#${MV}/tv_bin#g" \
		"${FILESDIR}"/${PN}d.init > "${T}"/${PN}d${MV} || die
}

src_install () {
	if use system-wine ; then
		echo ${PN}
		make_winewrapper
		exeinto /opt/${PN}
		doexe wine/drive_c/TeamViewer/*
	else
		# install scripts and .reg
		insinto /opt/${PN}/tv_bin
		doins -r *

		exeinto /opt/${PN}/tv_bin
		doexe TeamViewer_Desktop
		exeinto /opt/${PN}/tv_bin/script
		doexe script/teamviewer script/tvw_{aux,config,exec,extra,main,profile}

		dosym /opt/${PN}/tv_bin/script/${PN} /opt/bin/${PN}

		# fix permissions
		fperms 755 /opt/${PN}/tv_bin/wine/bin/wine{,-preloader,server}
		fperms 755 /opt/${PN}/tv_bin/wine/drive_c/TeamViewer/TeamViewer.exe
		find "${D}"/opt/${PN} -type f -name "*.so*" -execdir chmod 755 '{}' \;
	fi

	# install daemon binary
	exeinto /opt/${PN}/tv_bin
	doexe ${PN}d

	# set up logdir
	keepdir /var/log/${PN}
	dosym /var/log/${PN} /opt/${PN}/logfiles

	# set up config dir
	keepdir /etc/${PN}
	dosym /etc/${PN} /opt/${PN}/config

	doinitd "${T}"/${PN}d${MV}
	systemd_newunit script/${PN}d.service ${PN}d${MV}.service

	newicon -s 48 desktop/${PN}.png ${PN}.png
	dodoc ../doc/*.txt
	make_desktop_entry ${PN} TeamViewer ${PN}
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update

	if use system-wine ; then
		echo
		eerror "IMPORTANT NOTICE!"
		elog "Using ${PN} with system wine is not supported and experimental."
		elog "Do not report gentoo bugs while using this version."
		echo
	fi

	eerror "STARTUP NOTICE:"
	elog "You cannot start the daemon via \"teamviewer --daemon start\"."
	elog "Instead use the provided gentoo initscript:"
	elog "  /etc/init.d/${PN}d${MV} start"
	elog
	elog "Logs are written to \"/var/log/teamviewer${MV}\""
}

pkg_postrm() {
	gnome2_icon_cache_update
}
