# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python{3_3,3_4} )

inherit distutils-r1 user

DESCRIPTION="A caching proxy for package downloads"
HOMEPAGE="http://blog.tremily.us/posts/package-cache/"
if [[ "${PV}" == "9999" ]]; then
	inherit git-2
	EGIT_BRANCH="master"
	EGIT_REPO_URI="git://github.com/wking/${PN}.git"
	SRC_URI=""
else
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
fi

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="${PYTHON_DEPS}"
DEPEND="${PYTHON_DEPS}"

pkg_setup() {
	enewuser "${PN}" -1 -1 -1 portage
}

src_install() {
	distutils-r1_src_install
	doinitd "contrib/openrc/init.d/${PN}"
}
