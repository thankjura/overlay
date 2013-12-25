# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Meta package for GNOME-Light, merge this package to install"
HOMEPAGE="http://www.gnome.org/"
LICENSE="metapackage"
SLOT="2.0"
IUSE="cups +gnome-shell"

# when unmasking for an arch
# double check none of the deps are still masked !
KEYWORDS="~amd64 ~x86"

# XXX: Note to developers:
# This is a wrapper for the 'light' GNOME 3 desktop, and should only consist of
# the bare minimum of libs/apps needed. It is basically gnome-base/gnome without
# any apps, but shouldn't be used by users unless they know what they are doing.
RDEPEND="!gnome-base/gnome
	=gnome-base/gnome-core-libs-3.10*[cups?]

	=gnome-base/gnome-session-3.10*
	=gnome-base/gnome-menus-3.10*
	=gnome-base/gnome-settings-daemon-3.10*[cups?]
	=gnome-base/gnome-control-center-3.10*[cups?]

	=gnome-base/nautilus-3.10*

	gnome-shell? (
		=x11-wm/mutter-3.10*
		=gnome-base/gnome-shell-3.10* )

	=x11-themes/gnome-icon-theme-3.10*
	=x11-themes/gnome-icon-theme-symbolic-3.10*
	=x11-themes/gnome-themes-standard-3.10*

	=x11-terms/gnome-terminal-3.10*
"
DEPEND=""
PDEPEND=">=gnome-base/gvfs-1.18.0"
S="${WORKDIR}"

pkg_pretend() {
	if ! use gnome-shell; then
		# Users probably want to use e16, sawfish, etc
		ewarn "You're installing neither GNOME Shell nor GNOME Fallback!"
		ewarn "You will have to install and manage a window manager by yourself"
		# https://bugs.gentoo.org/show_bug.cgi?id=303375
		ewarn "See: <add link to docs about component handling in gnome-session>"
	fi
}
