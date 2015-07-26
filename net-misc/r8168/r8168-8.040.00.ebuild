# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit linux-mod

DESCRIPTION="Linux driver for Realtek RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller"
HOMEPAGE="http://www.realtek.com.tw/Downloads/downloadsView.aspx?Langid=1&PNid=13&PFid=5&Level=5&Conn=4&DownTypeID=3&GetDown=false"
SRC_URI="http://12244.wpc.azureedge.net/8012244/drivers/rtdrivers/cn/nic/0002-${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND=""

RESTRICT="test"

BUILD_TARGETS="modules"
MODULE_NAMES="r8168()"

src_compile() {
	BUILD_PARAMS="KERNELDIR=${KV_OUT_DIR}"
	MAKEOPTS+=" V=1"
	linux-mod_src_compile
	mv src/r8168.ko* .
}
