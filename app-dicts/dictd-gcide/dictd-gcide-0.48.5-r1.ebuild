# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=dict-gcide
DESCRIPTION="Collaborative International Dictionary of English (incl. Webster 1913) for dict"
HOMEPAGE="http://www.dict.org/"
SRC_URI="mirror://debian/pool/main/d/${MY_PN}/${MY_PN}_${PV}.tar.xz -> ${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"

DEPEND=">=app-text/dictd-1.5.5
	!app-dicts/dictd-web1913"

S=${WORKDIR}/${MY_PN}-${PV}

src_compile() {
	emake -j1 db
}

src_install() {
	insinto /usr/share/dict
	doins gcide.dict.dz gcide.index || die
}
