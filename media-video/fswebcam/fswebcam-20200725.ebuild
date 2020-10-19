# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="7"

DESCRIPTION="A neat and simple webcam app which captures images from a V4L1/V4L2 compatible device"
HOMEPAGE="https://www.sanslogic.co.uk/fswebcam/"
SRC_URI="https://www.sanslogic.co.uk/fswebcam/files/${P}.tar.xz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~arm"

IUSE="+v4l +v4l2"

DEPEND=">=media-libs/gd-2[png,jpeg,truetype]
	v4l? ( sys-kernel/linux-headers )
	v4l2? ( sys-kernel/linux-headers )"

src_configure() {
	local myconf
	use v4l || myconf="${myconf} --disable-v4l1"
	use v4l2 || myconf="${myconf} --disable-v4l2"
	econf ${myconf}
}

src_install() {
	dobin fswebcam
	dodoc README CHANGELOG example.conf
	doman fswebcam.1
}
