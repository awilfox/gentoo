# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils

DESCRIPTION="Raspberry Pi userspace tools and libraries"
HOMEPAGE="https://github.com/raspberrypi/userland"

if [[ ${PV} == 9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/${PN/-//}.git"
	SRC_URI=""
	KEYWORDS=""
else
	GIT_COMMIT="703a2c4"
	SRC_URI="https://github.com/raspberrypi/userland/tarball/${GIT_COMMIT} -> ${P}.tar.gz"
	KEYWORDS="~arm"
	S="${WORKDIR}/raspberrypi-userland-${GIT_COMMIT}"
fi

RDEPEND="!media-libs/raspberrypi-userland-bin
	wayland? ( dev-libs/wayland )"
DEPEND="${RDEPEND}
	wayland? ( virtual/pkgconfig )"

IUSE="examples wayland"
LICENSE="BSD"
SLOT="0"

# TODO:
# * port vcfiled init script
# * stuff is still installed to hardcoded /opt/vc location, investigate whether
#   anything else depends on it being there
# * live ebuild

src_unpack() {
	if [[ ${PV} == 9999* ]]; then
		git-2_src_unpack
	else
		default
	fi
}

src_prepare() {
	# init script for Debian, not useful on Gentoo
	sed -i "/DESTINATION \/etc\/init.d/,+2d" interface/vmcs_host/linux/vcfiled/CMakeLists.txt || die

	# wayland egl support
	epatch "${FILESDIR}"/next-resource-handle.patch \
		"${FILESDIR}"/wayland-wsys.patch
}

src_install() {
	cmake-utils_src_install

	# provide OpenGL ES v1 according to https://github.com/raspberrypi/firmware/issues/78
	dosym libGLESv2.so /opt/vc/lib/libGLESv1_CM.so

	doenvd "${FILESDIR}"/04${PN}

	insinto /lib/udev/rules.d
	doins "${FILESDIR}"/92-local-vchiq-permissions.rules

	# enable dynamic switching of the GL implementation
	dodir /usr/lib/opengl
	dosym ../../../opt/vc /usr/lib/opengl/${PN}

	# tell eselect opengl that we do not have libGL
	touch "${ED}"/opt/vc/.gles-only

	insinto /opt/vc/lib/pkgconfig
	doins "${FILESDIR}"/bcm_host.pc
	doins "${FILESDIR}"/egl.pc
	doins "${FILESDIR}"/glesv2.pc
	if use wayland; then
	# Missing wayland-egl version from the patch; claim 9.0 (a mesa version) for now, so gst-plugins-bad wayland-egl check is happy
		sed -i -e 's/Version:  /Version: 9.0/' "${ED}"/opt/vc/lib/pkgconfig/wayland-egl.pc
		doins "${ED}"/opt/vc/lib/pkgconfig/wayland-egl.pc # Maybe move?
	fi

	# some #include instructions are wrong so we need to fix them
	einfo "Fixing #include \"vcos_platform_types.h\""
	for file in $(grep -l "#include \"vcos_platform_types.h\"" "${D}"/opt/vc/include/* -r); do
		einfo "  Fixing file ${file}"
		sed -i "s%#include \"vcos_platform_types.h\"%#include \"interface/vcos/pthreads/vcos_platform_types.h\"%g" ${file}
	done
	einfo "Fixing #include \"vcos_platform.h\""
	for file in $(grep -l "#include \"vcos_platform.h\"" "${D}"/opt/vc/include/* -r); do
		einfo "  Fixing file ${file}"
	sed -i "s%#include \"vcos_platform.h\"%#include \"interface/vcos/pthreads/vcos_platform.h\"%g" ${file}
	done
	einfo "Fixing #include \"vchost_config.h\""
	for file in $(grep -l "#include \"vchost_config.h\"" "${D}"/opt/vc/include/* -r); do
		einfo "  Fixing file ${file}"
		sed -i "s%#include \"vchost_config.h\"%#include \"interface/vmcs_host/linux/vchost_config.h\"%g" ${file}
	done

	if use examples ; then
		dodir /usr/share/doc/${PF}/examples
		mv "${D}"/opt/vc/src/hello_pi "${D}"/usr/share/doc/${PF}/examples/ || die
		rm -fr "${D}"/opt/vc/src
	else
		rm -fr "${D}/opt/vc/src"
	fi
}
