# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib pax-utils

DESCRIPTION="Distributed, fault-tolerant and schema-free document-oriented database"
HOMEPAGE="https://couchdb.apache.org/"
SRC_URI="https://dlcdn.apache.org/couchdb/source/${PV}/apache-${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="test doc man"

RDEPEND="
		>=dev-libs/icu-76.1
		>=dev-lang/erlang-26.2.4
		<dev-lang/erlang-28
		dev-libs/openssl:0
		sys-process/psmisc
"

DEPEND="
	${RDEPEND}
"

BDEPEND="
	dev-util/rebar:3
	dev-build/autoconf-archive
	doc? ( sys-apps/help2man dev-lang/python )
	man? ( sys-apps/help2man dev-lang/python )
	test? ( dev-lang/python )
"

RESTRICT=test

S="${WORKDIR}/apache-${P}"


src_configure() {
	econf \
		--with-erlang="${EPREFIX}"/usr/$(get_libdir)/erlang/usr/include \
		--js-engine=quickjs \
		--disable-spidermonkey \
		--user=couchdb \
		$( (use doc || use man) || echo "--disable-docs")
}

src_compile() {
	emake release
}

src_test() {
	emake distcheck
}

src_install() {
	mkdir -p "${D}"/{etc,opt}
	mv "${S}/rel/couchdb/etc" "${D}/etc/couchdb"
	mv "${S}/rel/couchdb" "${D}/opt/"
	dosym ../../etc/couchdb /opt/couchdb/etc

	keepdir /var/l{ib,og}/couchdb

	fowners couchdb:couchdb \
		/var/lib/couchdb \
		/var/log/couchdb

	for f in "${ED}"/etc/couchdb/*.d; do
		fowners root:couchdb "${f#${ED}}"
		fperms 0750 "${f#${ED}}"
	done
	for f in "${ED}"/etc/couchdb/*.ini; do
		fowners root:couchdb "${f#${ED}}"
		fperms 0440 "${f#${ED}}"
	done
	# couchdb needs to write to local.ini on first start
	fowners couchdb:couchdb "/opt/couchdb/etc/local.ini"
	fperms  0640 "/opt/couchdb/etc/local.ini"

	insinto /etc/couchdb/default.d
	insopts -m0640 -oroot -gcouchdb
	doins "${FILESDIR}/10_gentoo.ini"

	rm "${ED}/opt/couchdb/bin/couchdb.cmd"

	# we expect `man couchdb` to work instead of `man apachecouchdb`
	use man && (
		ln "${S}/share/docs/man/apachecouchdb.1" "${S}/share/docs/man/couchdb.1" 
		doman "${S}/share/docs/man/couchdb.1"
	)
	use doc && (
		dodoc -r "${S}/share/docs/html"
	)

	# bug 442616 (possibly no longer relevant when using quickjs instead of spidermonkey)
	#pax-mark mr "${D}/opt/couchdb/bin/couchjs"
	#pax-mark mr "${D}/opt/couchdb/lib/couch-${PV}/priv/couchjs"
}
