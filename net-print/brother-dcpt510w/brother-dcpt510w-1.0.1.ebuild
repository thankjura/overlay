# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Driver for the Brother DCP-T510W wifi multifuncional printer"
HOMEPAGE="http://solutions.brother.com/linux/en_us/index.html"
SRC_URI="https://download.brother.com/welcome/dlf103620/dcpt510wpdrv-${PV}-0.i386.deb"

MODEL="dcpt510w"

LICENSE="custom:brother"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+scan"

DEPEND="
	app-text/a2ps
	net-print/cups
	scan? (
		media-gfx/brscan5
	)
"
RDEPEND="${DEPEND}"
BDEPEND=""

PATCH="${FILESDIR}/fix_lp.patch"

S="${WORKDIR}/opt/brother/Printers/${MODEL}"

src_unpack() {
	ar x "${DISTDIR}/${A}" || die
	unpack "${WORKDIR}/data.tar.gz"
}

src_install() {
	local DEST=/opt/brother/Printers/${MODEL}

	cd ${S}/lpd || die
	exeinto ${DEST}/lpd
	doexe br${MODEL}filter filter_${MODEL}

	cd ${S}/inf || die
	insinto ${DEST}/inf
	doins br${MODEL}func br${MODEL}rc ImagingArea setupPrintcapij paperinfij2 PaperDimension
	doins -r lut

	cd "${S}"/cupswrapper || die
	exeinto ${DEST}/cupswrapper
	doexe cupswrapper${MODEL} brother_lpdwrapper_${MODEL}
	dosym ${DEST}/cupswrapper/cupswrapper${MODEL} /usr/libexec/cups/filter/cupswrapper${MODEL}
	dosym ${DEST}/cupswrapper/brother_lpdwrapper_${MODEL} /usr/libexec/cups/filter/brother_lpdwrapper_${MODEL}

	insinto ${DEST}/cupswrapper
	doins brother_${MODEL}_printer_en.ppd
	dosym ${DEST}/cupswrapper/brother_${MODEL}_printer_en.ppd \
		/usr/share/cups/model/Brother/brother_${MODEL}_printer_en.ppd

	#doexe usr/bin/cupswrapperdcpt510w
	#dodir /opt
}
