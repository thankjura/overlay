# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
CMAKE_BUILD_TYPE=Release
inherit cmake-utils toolchain-funcs git-r3

DESCRIPTION="Robo 3T — is a shell-centric crossplatform MongoDB management tool."

ROBOSHELL_COMMIT="865d2fb5686852e00c5cc814627b9993404a03c1"
ROBOMONGO_COMMIT="f48cffdb2c65dcedb756c20b95a6d6cdaf54b1ea"

HOMEPAGE="http://www.robomongo.org/"
#SRC_URI="https://github.com/Studio3T/robomongo/archive/v${PV}.tar.gz -> ${P}.tar.gz
#		 https://github.com/Studio3T/robomongo-shell/archive/${ROBOSHELL_COMMIT}.zip -> roboshell-3.4.zip"

EGIT_REPO_URI="https://github.com/Studio3T/robomongo.git"
EGIT_COMMIT=${ROBOMONGO_COMMIT}

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">dev-qt/qtcore-5.7
		>dev-qt/qtgui-5.7[gtk]
		>dev-qt/qtdbus-5.7
		>dev-qt/qtprintsupport-5.7
		>dev-qt/qtimageformats-5.7
		dev-libs/openssl:0
		>=dev-util/scons-2.4
"

RDEPEND="${DEPEND}"

CMAKE_IN_SOURCE_BUILD=true

src_prepare() {
	sed -i -e's/5.7.0\/QtGui/5.7.1\/QtGui/' src/robomongo/core/settings/SettingsManager.cpp
	cd ${WORKDIR}
	git clone https://github.com/Studio3T/robomongo-shell.git
	cd ${WORKDIR}/robomongo-shell
	scons mongo --ssl -j8 CXXFLAGS='-w' CFLAGS='-w' || die
	cd ${S}
}

src_configure() {
	rm -rf cmake/FindOpenSSL.cmake
	local mycmakeargs=(
		-DMongoDB_DIR="${WORKDIR}/robomongo-shell"
	)
	cmake-utils_src_configure
}

src_install() {
	newbin src/robomongo/robo3t robomongo
	newicon install/macosx/robomongo.iconset/icon_256x256.png robomongo.png
	make_desktop_entry robomongo Robomongo robomongo
	dodoc CHANGELOG COPYRIGHT LICENSE README.md
}
