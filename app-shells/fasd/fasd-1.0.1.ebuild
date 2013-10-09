# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Offers quick command-line access to files and directories, inspired by autojump, z and v."
HOMEPAGE="https://github.com/clvv/fasd"
SRC_URI="https://github.com/clvv/${PN}/archive/${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install || die "Install failed"
}

