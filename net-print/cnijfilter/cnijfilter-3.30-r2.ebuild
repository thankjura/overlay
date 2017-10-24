# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: net-print/cnijfilter-drivers/cnijfilter-driverss-3.30.ebuild,v 2.0 2015/08/04 03:10:53  Exp $

EAPI=6

MULTILIB_COMPAT=( abi_x86_32 )

PRINTER_MODEL=( "ip2700" "mx340" "mx350" "mx870" )
PRINTER_ID=( "364" "365" "366" "367" )

inherit autotools eutils flag-o-matic multilib-build

DESCRIPTION="Canon InkJet Printer Driver for Linux (Pixus/Pixma-Series)"
HOMEPAGE="http://support-my.canon-asia.com/contents/MY/EN/0100272402.html"
SRC_URI="http://gdlp01.c-wss.com/gds/4/0100002724/01/${PN}-source-${PV}-1.tar.gz"

SLOT="3/3.30"

KEYWORDS="~x86 ~amd64"

IUSE="cups debug servicetools +net usb ${PRINTER_MODEL[@]/#/canon_printers_}"
REQUIRED_USE="|| ( cups ${PRINTER_MODEL[@]/#/canon_printers_} )"

RESTRICT="mirror"

RDEPEND="${RDEPEND}
	>=net-print/cups-1.6.0[${MULTILIB_USEDEP}]
	app-text/ghostscript-gpl
	dev-libs/glib[${MULTILIB_USEDEP}]
	dev-libs/popt[${MULTILIB_USEDEP}]
	media-libs/tiff[${MULTILIB_USEDEP}]
	media-libs/libpng[${MULTILIB_USEDEP}]
	!cups? ( >=${CATEGORY}/${P}[${MULTILIB_USEDEP},cups] )"

DEPEND="virtual/libintl"

PATCHES=(
	"${FILESDIR}"/${PN}-3.20-4-ppd.patch
	"${FILESDIR}"/${PN}-3.20-1-libdl.patch
	"${FILESDIR}"/${PN}-3.40-4-libpng15.patch
	"${FILESDIR}"/${PN}-3.70-1-libexec-cups.patch
	"${FILESDIR}"/${PN}-3.70-1-libexec-backend.patch
	"${FILESDIR}"/${PN}-3.80-1-cups-1.6.patch
	"${FILESDIR}"/${PN}-3.70-6-headers.patch
	"${FILESDIR}"/${PN}-3.80-6-headers.patch
	"${FILESDIR}"/${PN}-3.70-6-cups-1.6.patch
)

dir_src_command() {
	local dirs=( ${1} ) cmd="${2}" args="${3}"
	(( $# < 2 )) && eeror "Invalid number of argument" && return 1

	for dir in "${dirs[@]}"; do
		pushd ${dir} || die
		case "${cmd}" in
			(eautoreconf)
			[[ -d po ]] && echo "no" | glib-gettextize --force --copy
			[[ ! -e configure.in ]] && [[ -e configures/configure.in.new ]] &&
				mv -f configures/configure.in.new configure.in
			${cmd} ${args}
			;;
			(econf)
			case ${dir} in
				(backendnet|cnijnpr|lgmon2)
					myeconfargs=(
						"--enable-progpath=/usr/bin"
						"--enable-libpath=/var/lib/cnijlib"
						"${myeconfargs[@]}"
					)
				;;
				(backend|cngpiji*|cnijbe|lgmon|pstocanonij)
					myeconfargs=(
						"--enable-progpath=/usr/bin"
						"${myeconfargs[@]}"
					)
				;;
			esac
			${cmd} ${args} ${myeconfargs[@]}
			;;
			(*)
			${cmd} ${args}
			;;
		esac
		popd || die
	done
}

pkg_setup() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ "${LINGUAS}" ]] || export LINGUAS="en"

	use abi_x86_32 && use amd64 && multilib_toolchain_setup "x86"

	CNIJFILTER_SRC+=( libs pstocanonij )
	PRINTER_SRC+=( cnijfilter )
	use_if_iuse usb && CNIJFILTER_SRC+=( backend )
	use_if_iuse net && CNIJFILTER_SRC+=( backendnet )
	if ! has usb; then
		(( ${PV:0:1} >= 3 )) || ( (( ${PV:0:1} == 2 )) && (( ${PV:2:2} >= 80 )) ) &&
			CNIJFILTER_SRC+=( backend )
	fi
	CNIJFILTER_SRC+=( cngpij )
	if (( ${PV:0:1} == 4 )); then
		PRINTER_SRC+=( lgmon2 )
		use_if_iuse net && PRINTER_SRC+=( cnijnpr )
	else
		PRINTER_SRC+=( lgmon cngpijmon )
		use_if_iuse net && PRINTER_SRC+=( cngpijmon/cnijnpr )
	fi

	if use servicetools; then
	if (( ${PV:0:1} == 4 )); then
		CNIJFILTER_SRC+=( cngpijmnt )
	elif (( ${PV:0:1} == 3 )) && (( ${PV:2:2} >= 80 )); then
		CNIJFILTER_SRC+=( cngpijmnt maintenance )
	else
		PRINTER_SRC+=( printui )
	fi
	fi

	if (( ${PV:0:1} == 4 )); then
		PRINTER_SRC=( bscc2sts "${PRINTER_SRC[@]}" )
		CNIJFILTER_SRC=( cmdtocanonij "${CNIJFILTER_SRC[@]}" cnijbe )
	fi
}

src_unpack() {
	debug-print-function ${FUNCNAME} "${@}"

	default
	mv ${PN}-* ${P} || die "Failed to unpack"
	cd "${S}"
}

src_prepare() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ "${PATCHES}" ]] && epatch "${PATCHES[@]}"

	eapply_user

	use cups && dir_src_command "${CNIJFILTER_SRC[*]}" "eautoreconf"

	local p pr prid
	for (( p=0; p<${#PRINTER_ID[@]}; p++ )); do
		pr=${PRINTER_MODEL[$p]} prid=${PRINTER_ID[$p]}
		if use canon_printers_${pr}; then
			mkdir ${pr} || die
			cp -a ${prid} "${PRINTER_SRC[@]}" ${pr} || die
			pushd ${pr} || die
			[[ -d ../com ]] && ln -s {../,}com
			dir_src_command "${PRINTER_SRC[*]}" "eautoreconf"
			popd
		fi
	done
}

src_configure() {
	debug-print-function ${FUNCNAME} "${@}"

	use cups && dir_src_command "${CNIJFILTER_SRC[*]}" "econf"

	local p pr prid
	for (( p=0; p<${#PRINTER_ID[@]}; p++ )); do
		pr=${PRINTER_MODEL[$p]} prid=${PRINTER_ID[$p]}
		if use canon_printers_${pr}; then
			pushd ${pr} || die
			dir_src_command "${PRINTER_SRC[*]}" "econf" "--program-suffix=${pr}"
			popd
		fi
	done
}

src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	local p pr prid
	for (( p=0; p<${#PRINTER_ID[@]}; p++ )); do
		pr=${PRINTER_MODEL[$p]} prid=${PRINTER_ID[$p]}
		if use canon_printers_${pr}; then
			pushd ${pr} || die
			dir_src_command "${PRINTER_SRC[*]}" "emake"
			popd
		fi
	done

	use cups && dir_src_command "${CNIJFILTER_SRC[*]}" "emake"
}

src_install()
{
	debug-print-function ${FUNCNAME} "${@}"

	local abi_libdir=/usr/$(get_libdir) p pr prid
	local abi_lib=$(usex abi_x86_64 64 32)
	local lib license lingua=false
	local -a DOCS

	(( ${#MULTILIB_COMPAT[@]} == 1 )) && abi_lib=

	use cups &&
	dir_src_command "${CNIJFILTER_SRC[*]}" "emake" "DESTDIR=\"${D}\" install"

	for (( p=0; p<${#PRINTER_ID[@]}; p++ )); do
		pr=${PRINTER_MODEL[$p]} prid=${PRINTER_ID[$p]}
		if use canon_printers_${pr}; then
			lingua=true
			pushd ${pr} || die
			dir_src_command "${PRINTER_SRC[*]}" "emake" "DESTDIR=\"${D}\" install"
			popd

			dolib.so ${prid}/libs_bin${abi_lib}/*.so*
			exeinto /var/lib/cnijlib
			doexe ${prid}/database/*
			insinto /usr/share/cups/model
			doins ppd/canon${pr}.ppd

			if use_if_iuse doc; then
			for lingua in ${LINGUAS}; do
				lingua="${lingua^^[a-z]}"
				[[ -f lproptions/lproptions-${pr}-${PV}${lingua}.txt ]] &&
				DOCS+=(lproptions/lproptions-${pr}-${PV}${lingua}.txt)
			done
			fi
		fi
	done

	if use cups && use_if_iuse net; then
		pushd com/libs_bin${abi_lib} || die
		for lib in lib*.so; do
			[[ -L ${lib} ]] && continue ||
			rm ${lib} && ln -s ${lib}.[0-9]* ${lib}
		done
		popd

		dolib.so com/libs_bin${abi_lib}/*.so*
		EXEOPTIONS="-m555 -glp -olp"
		exeinto /var/lib/cnijlib
		doexe com/ini/cnnet.ini
	fi

	if use cups && (( ${PV:0:1} == 4 )); then
		mkdir -p "${ED}"/usr/share/${PN} || die
		mv "${ED}"/usr/share/{cmdtocanonij,${PN}} || die
	fi

	if ${lingua} || use_if_iuse net; then
	for lingua in ${LINGUAS}; do
		lingua="${lingua^^[a-z]}"
		license=LICENSE-${PN}-${PV}${lingua}.txt
		[[ -e ${license%${lingua:0:1}.txt}.txt ]] &&
		mv -f ${license%{lingua:0:1}.txt} ${license}
		[[ -e ${license} ]] && DOCS+=(${license})
	done
	fi

	[[ "${DOCS[*]}" ]] && dodoc "${DOCS[@]}"
}

pkg_postinst() {
	debug-print-function ${FUNCNAME} "${@}"

	# XXX: set up ppd files to use newer CUPS backends
	if (( ${PV:0:1} < 3 )) || ( (( ${PV:0:1} == 3 )) && (( ${PV:2:1} == 0 )) ); then
		use cups || sed 's,cnij_usb,cnijusb,g' -i "${ED}"/usr/share/cups/model/canon*.ppd
	fi

	elog "To install a printer:"
	elog " * First, restart CUPS: 'service cupsd restart'"
	elog " * Go to http://127.0.0.1:631/ with your favorite browser"
	elog "   and then go to Printers/Add Printer"
	elog
	elog "You can consult the following for any issue/bug:"
	elog
	elog "${FILESDIR%/*}/README.md"
	elog "https://forums.gentoo.org/viewtopic-p-3217721.html"
	elog "https://bugs.gentoo.org/show_bug.cgi?id=130645"
}
