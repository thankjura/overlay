EAPI="5"

inherit eutils

DESCRIPTION="PyCharm"
HOMEPAGE="www.jetbrains.com/pycharm/"
SRC_URI="http://download-ln.jetbrains.com/python/${PN}-${PV}.tar.gz"

KEYWORDS="~x86 ~amd64"

DEPEND=">=virtual/jre-1.6"
RDEPEND="${DEPEND}"

SLOT="0"

S="${WORKDIR}/pycharm-${PV}"

src_install()
{	
	# copy files
  dodir /opt/${PN}
	insinto /opt/${PN}
	doins -r *
	
  # fix perms
  fperms a+x /opt/${PN}/bin/pycharm.sh || die "fperms failed"
	fperms a+x /opt/${PN}/bin/fsnotifier || die "fperms failed"
	fperms a+x /opt/${PN}/bin/fsnotifier64 || die "fperms failed"
	fperms a+x /opt/${PN}/bin/inspect.sh || die "fperms failed"
	
  # symlink
  dosym /opt/${PN}/bin/pycharm.sh /usr/bin/${PN}

  # desktop entry
	mv "bin/pycharm.png" "bin/${PN}.png"
  doicon "bin/${PN}.png"
	make_desktop_entry ${PN} "PyCharm (Professional)" /opt/${PN}/bin/${PN}.png
}
