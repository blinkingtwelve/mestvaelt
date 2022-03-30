# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..10} )
inherit distutils-r1

DESCRIPTION="The blissfully naive PostgreSQL database object manager"
HOMEPAGE="https://git.sr.ht/~nullenenenen/DBSamizdat https://pypi.org/project/DBSamizdat/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/psycopg[${PYTHON_USEDEP}]
	dev-python/toposort[${PYTHON_USEDEP}]
	"
DEPEND="${RDEPEND}"

