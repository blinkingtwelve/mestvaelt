# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit autotools mercurial

DESCRIPTION="A spamfilter reclassification plugin for Dovecot, supporting multiple backends"
HOMEPAGE="http://wiki2.dovecot.org/Plugins/Antispam"
EHG_REPO_URI="http://hg.dovecot.org/dovecot-antispam-plugin/"
EHG_REVISION="7f94cc6b4d8e"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

DEPEND=">=net-mail/dovecot-2"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoconf
	./autogen.sh || die "autogen failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	doman doc/dovecot-antispam.7
	dodoc README
}
