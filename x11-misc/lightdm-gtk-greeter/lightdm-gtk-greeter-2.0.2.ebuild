# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit versionator

DESCRIPTION="LightDM GTK+ Greeter"
HOMEPAGE="https://launchpad.net/lightdm-gtk-greeter"
SRC_URI="https://launchpad.net/lightdm-gtk-greeter/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz
	branding? ( https://dev.gentoo.org/~hwoarang/distfiles/lightdm-gentoo-patch-2.tar.gz )"

LICENSE="GPL-3 LGPL-3
	branding? ( CC-BY-3.0 )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86"
IUSE="ayatana branding"

COMMON_DEPEND="ayatana? ( dev-libs/libindicator:3 )
	x11-libs/gtk+:3
	>=x11-misc/lightdm-1.2.2"

DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	xfce-base/exo"

RDEPEND="${COMMON_DEPEND}
	x11-themes/gnome-themes-standard
	>=x11-themes/adwaita-icon-theme-3.14.1"

GENTOO_BG="gentoo-bg_65.jpg"

src_prepare() {
	# Ok, this has to be fixed in the tarball but I am too lazy to do it.
	# I will fix this once I decide to update the tarball with a new gentoo
	# background
	# Bug #404467
	if use branding; then
		sed -i -e "/xft-hintstyle/s:slight:hintslight:" \
			"${WORKDIR}"/${PN}.conf || die
	fi
	default
}

src_configure() {
	econf --enable-kill-on-sigterm \
		$(use_enable ayatana libindicator)
}

src_install() {
	default

	if use branding; then
		insinto /etc/lightdm/
		doins "${WORKDIR}"/${PN}.conf
		insinto /usr/share/lightdm/backgrounds/
		doins "${WORKDIR}"/${GENTOO_BG}
		sed -i -e \
			"/background/s:=.*:=/usr/share/lightdm/backgrounds/${GENTOO_BG}:" \
			"${D}"/etc/lightdm/${PN}.conf || die
		newdoc "${WORKDIR}"/README.txt README-background.txt
	fi
}
