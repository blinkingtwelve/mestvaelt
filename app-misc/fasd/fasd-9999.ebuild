# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit git-2 

DESCRIPTION="Fasd keeps track of files and directories you have accessed, so
that you can quickly reference them in the command line."
HOMEPAGE="https://github.com/clvv/fas"
EGIT_REPO_URI="https://github.com/clvv/fasd.git"


LICENSE="MIT"
SLOT="0"
KEYWORDS="~*"


src_install() {
	dobin fasd
	doman fasd.1
}
