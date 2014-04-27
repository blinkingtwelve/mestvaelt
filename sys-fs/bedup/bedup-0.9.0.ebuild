# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/bedup/bedup-9999.ebuild,v 1.1 2013/07/15 19:54:09 mgorny Exp $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3} )

#if LIVE
# Note: we ignore submodules since we use btrfs-progs-9999.
#EGIT_REPO_URI="git://github.com/g2p/bedup.git
#	https://github.com/g2p/bedup.git"
#inherit git-2
#endif

inherit distutils-r1

DESCRIPTION="Btrfs file de-duplication tool"
HOMEPAGE="https://github.com/g2p/bedup"
SRC_URI="https://pypi.python.org/packages/source/b/${PN}/${PN}-${PV}.tar.gz"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# pycparser is indirect dep but <2.09.1 causes issues.
# we need btrfs-progs with includes installed.
DEPEND=">=dev-python/cffi-0.5[${PYTHON_USEDEP}]
	>=dev-python/pycparser-2.09.1-r1[${PYTHON_USEDEP}]
	>=sys-fs/btrfs-progs-0.20_rc1_p358"
RDEPEND="${DEPEND}
	dev-python/alembic[${PYTHON_USEDEP}]
	dev-python/contextlib2[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/sqlalchemy[sqlite,${PYTHON_USEDEP}]
	virtual/python-argparse[${PYTHON_USEDEP}]"

