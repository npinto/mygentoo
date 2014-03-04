# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="b0f9be2cdea655b75d9cadab22f04333ebaf5e9e"
CROS_WORKON_TREE="a1f4a45aa1aa25719f5c9a76396d5ba2b3e2b67b"
CROS_WORKON_PROJECT="chromiumos/third_party/khronos"

inherit toolchain-funcs cros-workon

DESCRIPTION="OpenGL|ES mock library"
HOMEPAGE="http://www.khronos.org/opengles/2_X/"
SRC_URI=""

LICENSE="SGI-B-2.0"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-drivers/opengles-headers"
DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="khronos"

src_compile() {
	tc-export AR CC CXX LD NM RANLIB
	scons || die
}

src_install() {
	dolib libEGL.so libGLESv2.so
}
