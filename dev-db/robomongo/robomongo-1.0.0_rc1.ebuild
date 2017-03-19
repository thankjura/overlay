# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
CMAKE_BUILD_TYPE=Release
inherit cmake-utils toolchain-funcs

DESCRIPTION="Robomongo — is a shell-centric crossplatform MongoDB management tool."

ROBOSHELL_COMMIT="9fa2d97e189eac23451f7e565fc46bda86bca690"
ROBOMONGO_COMMIT="43bf28968bd6cc0e4c55c578605e9f2441ecaf26"

MY_PV=${PV/_/-}
OPENSSL_VERS="1.0.1p"
HOMEPAGE="http://www.robomongo.org/"
#SRC_URI="https://github.com/paralect/robomongo/archive/v${MY_PV}.tar.gz
SRC_URI="https://github.com/Studio3T/robomongo/archive/${ROBOMONGO_COMMIT}.zip -> robomongo-${MY_PV}.zip
		 https://github.com/paralect/robomongo-shell/archive/${ROBOSHELL_COMMIT}.zip -> roboshell-3.2.zip
		 https://ftp.openssl.org/source/old/1.0.1/openssl-${OPENSSL_VERS}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">dev-qt/qtcore-5
		>dev-qt/qtgui-5[gtk]
		>dev-qt/qtdbus-5
		>dev-qt/qtprintsupport-5
		>dev-qt/qtimageformats-5"

RDEPEND="${DEPEND}"

S=${WORKDIR}"/"${PN}"-"${ROBOMONGO_COMMIT}
MONGODB_DIR=${WORKDIR}"/robomongo-shell-"${ROBOSHELL_COMMIT}
OPENSSL_DIR=${WORKDIR}"/openssl-"${OPENSSL_VERS}
CMAKE_IN_SOURCE_BUILD=true

src_prepare() {
	epatch "${FILESDIR}/build_fix_robomongo.patch"
	epatch "${FILESDIR}/${P}-fix_qurl.patch"
	cd ${MONGODB_DIR}
	epatch "${FILESDIR}/build_fix.patch"
	scons mongo --release --disable-warnings-as-errors CC="$(tc-getCC)" CXX="$(tc-getCXX)" ${MAKEOPTS}
	cd ${S}
}

src_configure() {
	mycmakeargs=(
		-DMongoDB_DIR:PATH=${MONGODB_DIR}
		-DCMAKE_PREFIX_PATH="${MONGODB_DIR};${OPENSSL_DIR}"
	)
	cmake-utils_src_configure
}

src_compile() {
	cd ${OPENSSL_DIR}
	./config shared
	make
	mkdir lib
	cp libssl* libcrypto* lib/
	cd ${S}
	default
}

src_install() {
	cd ${BUILD_DIR}
	dobin src/robomongo/robomongo
	newicon install/macosx/Robomongo.iconset/icon_256x256.png robomongo.png
	make_desktop_entry robomongo Robomongo robomongo
	dodoc CHANGELOG COPYRIGHT LICENSE README.md
}
