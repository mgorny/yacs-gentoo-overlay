# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/collectd-web/collectd-web-0.4.0.ebuild,v 1.2 2012/12/28 09:35:59 qnikst Exp $

EAPI=3

inherit webapp eutils

DESCRIPTION="Collectd-web is a web-based front-end for RRD data collected by collectd"
HOMEPAGE="http://collectdweb.appspot.com/"
SRC_URI="https://github.com/httpdss/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""

need_httpd_cgi

S="${WORKDIR}/httpdss-collectd-web-a23c49f"

DEPEND="dev-perl/HTML-Parser
	net-analyzer/rrdtool[perl]
	dev-perl/JSON
	virtual/perl-CGI
	dev-perl/URI
	virtual/perl-Time-Local
	virtual/ttf-fonts"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch ${FILESDIR}/${PN}.response_code.patch || die "epatch failed"
}
src_install() {
	webapp_src_preinst

	cd "${S}"/cgi-bin
	insinto  "${MY_CGIBINDIR}"
	doins -r .

	cd "${S}"
	insinto  "${MY_HTDOCSDIR}"
	doins -r iphone
	doins -r media
	doins index.html

	webapp_src_install
}
